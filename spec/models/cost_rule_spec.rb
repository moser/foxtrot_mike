require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CostRule do
  before(:each) do
    @valid_attributes = {
      :depends_on => "value for depends_on",
      :rate => 1,
      :cost => 1,
      :round => "value for round"
    }
  end

  it "should create a new instance given valid attributes" do
    CostRule.create!(@valid_attributes)
  end
end
