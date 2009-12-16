require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flight do
  before(:each) do
    @valid_attributes = {
      :duration => 1,
      :departure => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Flight.create!(@valid_attributes)
  end
  
  it "should be revisable" do
    Flight.new.should respond_to :revisions
  end
end
