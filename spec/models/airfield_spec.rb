require File.dirname(__FILE__) + '/../spec_helper'

describe Airfield do
  before(:each) do
    @airfield = Airfield.new
  end

  it "should be valid" do
    @airfield.should be_valid
  end
end
