class Group < ActiveRecord::Base
  has_many :people
  has_many :planes
  
  def to_s
    name
  end
end
