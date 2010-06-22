require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Group do
  before(:each) do
    @valid_attributes = {
      :name => "Group"
    }
  end

  it "should create a new instance given valid attributes" do
    Group.create!(@valid_attributes)
  end
  
  it "should respond to to_s" do
    Group.new(:name => "hua").to_s.should == "hua"
  end
end
