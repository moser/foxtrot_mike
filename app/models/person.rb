class Person < ActiveRecord::Base
  include UuidHelper
  include Membership

  has_paper_trail

  has_many :accounts
  belongs_to :financial_account
  has_many :crew_members
  has_many :person_cost_category_memberships
  has_many :liabilities
  has_many :licenses
  has_many_current :licenses
  belongs_to :group
  membership :person_cost_category_memberships
  
  validates_presence_of :firstname, :lastname, :group

  #added methods may rely on associations
  
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

  def relevant_licenses_for(flight)
    if flight 
      time = flight.departure || DateTime.now
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

  def flights
    AbstractFlight.include_all.where(:id => [Trainee.where(:person_id => id), PilotInCommand.where(:person_id => id)].flatten.map(&:abstract_flight_id))
  end

  def <=>(other)
    "#{lastname}, #{firstname}" <=> "#{other.lastname}, #{other.firstname}"
  end

  def info
    "#{group.name}"
  end
end
