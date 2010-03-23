class Person < ActiveRecord::Base
  include UuidHelper
  
  has_many :crew_members

  #added methods may rely on associations
  include PersonAddition
  
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
  
  # Returns if the person is a trainee on the given flight
  def trainee?(flight)
    false
  end
  
  def instructor?(flight)
    false
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
    [ :id, :lastname, :firstname, :birthdate, :email ]
  end
  
  def shared_attributes
    self.attributes.reject { |k, v| !self.class.shared_attribute_names.include?(k.to_sym) }
  end
end
