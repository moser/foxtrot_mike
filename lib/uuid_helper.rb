require 'rubygems'
require 'uuidtools'
 
module UuidHelper
  def self.included(base)
    base.set_primary_key :id
    base.before_create :set_uuid
  end
  
private
  def set_uuid
    self.id = UUIDTools::UUID.random_create().to_s if self.id.nil?
  end
end
