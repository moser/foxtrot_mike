require 'rubygems'
require 'uuidtools'
 
module UuidHelper
  def before_create()
    self.id = UUIDTools::UUID.random_create().to_s if self.id.nil?
  end
end