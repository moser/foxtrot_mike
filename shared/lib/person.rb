class Person < ActiveRecord::Base
  #server side
  if RAILS_ENV
    acts_as_revisable
    has_many :accounts
    belongs_to :person_cost_category
  end  
  
  def self.find_by_name(str)
    find :all, 
         :conditions => 
            [ "firstname || ' ' || lastname || ' ' || firstname LIKE :str", { :str => "%#{str}%" } ],
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
