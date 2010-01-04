class Plane < ActiveRecord::Base
  include PlaneAddition
  
  has_many :flights
end
