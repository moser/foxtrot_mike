require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  before(:each) do
    @valid_attributes = {
      :name => "Group"
    }
  end

  it { should validate_presence_of :name }

  it "should create a new instance given valid attributes" do
    Group.create!(@valid_attributes)
  end
  
  it "should respond to to_s" do
    Group.new(:name => "hua").to_s.should == "hua"
  end
end
