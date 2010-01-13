class Plane < ActiveRecord::Base
  include UuidHelper
  
  has_many :flights
  
  #added methods may rely on associations
  include PlaneAddition
  
  def to_s
    registration || ""
  end
end
