class Person < ActiveRecord::Base
  include PersonAddition  
  
  def self.find_by_name(str)
    find :all, 
         :conditions => 
            [ "lower(firstname || ' ' || lastname || ' ' || firstname) LIKE :str", { :str => "%#{str.downcase}%" } ],
         :order => "lastname, firstname" 
  end
  
  # Returns if the person is a trainee on the given flight
  def trainee?(flight)
    false
  end
  
  def name
    (firstname || '') + ' ' + (lastname || '')
  end
end
