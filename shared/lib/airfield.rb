class Airfield < ActiveRecord::Base
  include UUIDHelper

  has_many :flights_from, :foreign_key => 'from_id', :class_name => 'Flight'
  has_many :flights_to, :foreign_key => 'to_id', :class_name => 'Flight'
  
  def to_s
    registration || name || ''
  end
end
