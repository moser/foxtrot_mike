require 'rubygems'
require 'uuidtools'
 
module UUIDHelper
  def before_create()
    self.id = UUIDTools::UUID.timestamp_create().to_s
  end
end
