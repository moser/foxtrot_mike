class Plane < ActiveRecord::Base
  include PlaneAddition
  include UUIDHelper
  
  has_many :flights
  
  def to_s
    registration || ""
  end
end
