require 'csv'

class Person < ActiveRecord::Base
  MemberStates = [ :active, :passive, :passive_with_voting_right, :donor ]

  include UuidHelper
  include Membership
  include Current
  include AccountingEntryInvalidation

  has_many :accounts
  has_many :flights_on_seat1, :foreign_key => 'seat1_person_id', :class_name => 'AbstractFlight', :include => AbstractFlight::IncludeAll 
  has_many :flights_on_seat2, :foreign_key => 'seat2_person_id', :class_name => 'AbstractFlight', :include => AbstractFlight::IncludeAll 
  has_many :financial_account_ownerships, :as => :owner, :autosave => true, :after_add => :association_changed, :after_remove => :association_changed
  has_one_current :financial_account_ownership
  has_many :person_cost_category_memberships
  has_many :liabilities
  has_many :licenses
  has_many_current :licenses
  has_many :wire_launches, :as => :operator
  belongs_to :group
  membership :person_cost_category_memberships

  belongs_to :duplicate_of, class_name: 'Person'
  has_many :duplicates, class_name: 'Person', foreign_key: 'duplicate_of_id'

  validates_presence_of :firstname, :lastname, :group

  default_scope order("lastname asc, firstname asc")

  def financial_account=(o)
    if new_record?
      financial_account_ownerships << FinancialAccountOwnership.create(:financial_account => o, :owner => self)
    end
  end

  def financial_account
    current_financial_account_ownership && current_financial_account_ownership.financial_account
  end

  def financial_account_at(date)
    financial_account_ownership_at(date) && financial_account_ownership_at(date).financial_account
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

  def self.mergable(person)
    self.where(duplicate_of_id: nil).where("id <> ?", person.id).all
  end

  def self.debitors
    FinancialAccount.debitors.map do |account|
      last_deposit = account.accounting_entries_to.map { |entry| entry.accounting_session && entry.accounting_session.accounting_date }.compact.max
      accounting_entries = account.accounting_entries_from.select do |accounting_entry| 
        accounting_entry.accounting_session &&
        accounting_entry.accounting_session.accounting_date &&
        accounting_entry.accounting_session.accounting_date > last_deposit
      end
      positions = accounting_entries.group_by(&:category_text).map do |category_text, entries|
        { category: category_text, value: entries.map(&:value).sum }
      end
      account.owners.select { |owner| owner.is_a?(Person) }.map do |person|
        person.attributes.select { |k, _| [:firstname, :lastname, :sex, :address1, :address2, :zip, :city, :email].map(&:to_s).include?(k) }.merge({
          balance: account.balance,
          account_number: account.number,
          last_deposit: last_deposit,
          positions: positions
        })
      end
    end.flatten
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

  def flights(relation = nil)
    relation ||= AbstractFlight.include_all
    relation.where("seat1_person_id = ? OR seat2_person_id = ?", id, id) #TODO reject those flights, where the person is not involved 
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

  def as_json(options)
    { :id => id,
      :firstname => firstname,
      :lastname => lastname,
      :group_id => group_id,
      :group_name => group.name,
      :disabled => disabled,
      :deleted => deleted,
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

  def merge_to(other_person)
    flights_on_seat1.each do |f|
      f.update_attribute :seat1_person, other_person
    end
    flights_on_seat2.each do |f|
      f.update_attribute :seat2_person, other_person
    end
    update_attributes disabled: true, deleted: true, duplicate_of_id: other_person.id
  end

  def merge_info
    "#{name} (#{flights_on_seat1.count + flights_on_seat2.count} #{AbstractFlight.l(:plural)})
     #{!current_person_cost_category_memberships.empty? ? 'Cat' : ''}
     #{current_financial_account_ownership && 'Acc'}"
  end

  def self.to_csv(models, options = {})
    columns = [ :firstname, :lastname, :phone1, :phone2, :cell, :email, :address1, :address2, :zip, :city, :birthdate ]
    CSV.generate(options) do |csv|
      csv << columns.map { |col| Person.l(col) }
      models.each do |model|
        csv << columns.map { |col| model.send(col) } if !model.deleted
      end
    end
  end

  def self.import(hashes)
    ActiveRecord::Base.transaction do
      hashes.each do |hash|
        begin
          import_group(hash)
          import_financial_account(hash)
          person_cost_category = import_person_cost_category(hash)
          license_hash = hash.select { |k,_| k.to_s.start_with?('license_') }.with_indifferent_access
          hash = hash.select { |k,_| !k.to_s.start_with?('license_') }
          person = Person.create!(hash)
          if person_cost_category
            PersonCostCategoryMembership.create!(person: person, person_cost_category: person_cost_category, valid_from: Date.today)
          end
          if license_hash.keys.sort.map(&:to_s) == ['license_class', 'license_level']
            lpc = LegalPlaneClass.where(name: license_hash[:license_class]).first
            if lpc
              person.licenses.create!(valid_from: Date.today,
                                      level: license_hash[:license_level],
                                      legal_plane_classes: [lpc],
                                      name: 'Imported license')
            end
          end
        rescue => e
          raise "#{e.message} - #{hash.inspect}"
        end
      end
    end
  end

private
  def association_changed(obj = nil)
    invalidate_concerned_accounting_entries
  end

  def self.import_group(hash)
    group_name = hash.delete(:group)
    if group_name
      hash[:group_id] = Group.where(name: group_name).first_or_create.id
    end
  end

  def self.import_financial_account(hash)
    financial_account_id = hash.delete(:financial_account_id)
    if financial_account_id
      hash[:financial_account] = FinancialAccount.find(financial_account_id)
    else
      attrs = FinancialAccount.attribute_names - %w(id updated_at created_at)
      financial_account_attrs = Hash[hash.select { |k,_| attrs.map {|k| "financial_account_#{k}"}.include?(k.to_s) }.map { |k,v| [k.to_s.gsub('financial_account_',''),v] }]
      hash.delete_if { |k,_| attrs.map {|k| "financial_account_#{k}"}.include?(k.to_s) }
      if (financial_account_attrs.keys & %w(number name)).count >= 2
        hash[:financial_account] = FinancialAccount.create!(financial_account_attrs)
      end
    end
  end

  def self.import_person_cost_category(hash)
    person_cost_category_name = hash.delete(:person_cost_category)
    if person_cost_category_name
      person_cost_category = PersonCostCategory.where(name: person_cost_category_name).first
      raise "Person cost category not found: #{person_cost_category_name}" if person_cost_category.nil?
    end
    person_cost_category
  end
end
