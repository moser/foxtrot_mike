require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flight do
  before(:each) do
    @valid_attributes = {
      :duration => 1,
      :departure => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Flight.create(@valid_attributes)
  end
  
  it "should be revisable" do
    Flight.new.should respond_to :revisions
  end
  
  it "should have a complete history" do
    f = Flight.create
    f.update_attribute :plane_id, Plane.generate!.id
    sleep 1
    f.seat1 = Person.generate!
    sleep 1
    f.seat2 = Person.generate!
    sleep 1
    f.seat2 = 1
    sleep 1
    f.update_attribute :from_id, Airfield.generate!.id
    p f
    #f.history.each { |r|
    #  puts r.revisable_current_at
    #  puts r.class
    #}
  end
end
