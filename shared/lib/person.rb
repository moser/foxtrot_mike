class Person < ActiveRecord::Base
  include PersonAddition
  include UUIDHelper

  
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
  
  def name
    (firstname || '') + ' ' + (lastname || '')
  end
  
  def to_s
    name
  end
end
