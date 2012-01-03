class Person < ActiveRecord::Base
  MemberStates = [ :active, :passive, :passive_with_voting_right, :donor ]

  include UuidHelper
  include Membership
  include Current
  include AccountingEntryInvalidation

  has_paper_trail

  has_many :accounts
  has_many :crew_members
  has_many :financial_account_ownerships, :as => :owner, :autosave => true, :after_add => :association_changed, :after_remove => :association_changed
  has_one_current :financial_account_ownership
  has_many :person_cost_category_memberships
  has_many :liabilities
  has_many :licenses
  has_many_current :licenses
  has_many :wire_launches, :as => :operator
  belongs_to :group
  membership :person_cost_category_memberships

  validates_presence_of :firstname, :lastname, :group

  default_scope order("lastname asc, firstname asc")

  def financial_account
    current_financial_account_ownership && current_financial_account_ownership.financial_account 
  end

  def financial_account_id
    financial_account && financial_account.id
  end

  def self.find_all_by_name(str)
    find :all, 
         :conditions => 
            [ "lower(firstname || ' ' || lastname || ' ' || firstname) LIKE :str", { :str => "%#{str.downcase}%" } ],
         :order => "lastname, firstname" 
  end

  def self.find_by_name(str)
    arr = find_all_by_name(str)
    if arr.size == 1
      arr[0]
    else
      nil
    end
  end

  def has_relevant_licenses_for(f)
    !relevant_licenses_for(f).empty?
  end

  def relevant_licenses_for(flight)
    if flight 
      time = flight.departure_date || Date.today
      if flight.plane
        return licenses_at(time).select { |l| l.legal_plane_classes.include?(flight.plane.legal_plane_class) }
      end
    end
    []
  end

  # Returns if the person is a trainee on the given flight
  def trainee?(flight)
    if flight
      (relevant_licenses_for(flight).reject { |l| l.trainee? }).empty?
    else
      false
    end
  end

  def instructor?(flight)
    if flight
      !(relevant_licenses_for(flight).select { |l| l.instructor? }).empty?
    else
      false
    end
  end

  def name
    (firstname || '') + ' ' + (lastname || '')
  end

  def name?(str)
    str.is_a?(String) && name.downcase == str.downcase
  end

  def to_s
    name
  end

  def self.shared_attribute_names
    [ :id, :lastname, :firstname, :birthdate, :email, :group_id ]
  end

  def shared_attributes
    self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
  end

  def flights(relation = nil)
    relation ||= AbstractFlight.include_all
    relation.where(:id => [Trainee.where(:person_id => id), PilotInCommand.where(:person_id => id)].flatten.map(&:abstract_flight_id))
  end

  def flights_liable_for(relation = nil)
    relation ||= Flight.include_all
    relation.joins(:liabilities).where("liabilities.person_id = ?", self.id)
  end

  def <=>(other)
    "#{lastname}, #{firstname}" <=> "#{other.lastname}, #{other.firstname}"
  end

  def info
    "#{group.name}"
  end

  def find_concerned_accounting_entry_owners(&blk)
    blk ||= lambda { |r| r }
    blk.call(flights(Flight.include_all)) + blk.call(flights_liable_for)
  end

  def to_j
    { :id => id,
      :firstname => firstname,
      :lastname => lastname,
      :group_id => group_id,
      :group_name => group.name,
      :licenses => licenses.map { |e| e.to_j } }
  end

  def member_state
    (read_attribute(:member_state) || "").to_sym
  end

  def lvb_member_state(date = Date.today)
    unless primary_member
      :secondary
    else
      if active?
        if age_at(date) > 21
          :adults
        elsif age_at(date) >= 14
          :youths
        elsif age_at(date) >= 10
          :children
        else
          :young_children
        end
      else
        :passive
      end
    end
  end

  def active?
    :active == member_state
  end

  def donor?
    :donor == member_state
  end

  def passive?
    :passive == member_state || :passive_with_voting_right == member_state
  end

  def passive_with_voting_right?
    :passive_with_voting_right == member_state
  end

  def voting_right?(date = Date.today)
    (active? || passive_with_voting_right?) && age_at(date) >= 18
  end

  def age_at(date)
    bdate = birthdate.to_date
    date = date.to_date
    years = date.year - bdate.year
    if bdate + years.year > date
      years - 1
    else
      years
    end
  end

  def age
    age_at(Date.today)
  end
private
  def association_changed(obj = nil)
    delay.invalidate_concerned_accounting_entries
  end
end
