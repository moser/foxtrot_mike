class Group < ActiveRecord::Base
  has_many :people
  has_many :planes
end
