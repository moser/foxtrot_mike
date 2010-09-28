require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  before(:each) do
    @instance = ApplicationController.new
  end

  it "should parse the after param"
  
  it "should parse json params"
  
  it "should parse dates inside json params" do
    d = DateTime.new(2010, 4, 25, 13, 44, 12, 0)
    @instance.parse_json_dates(ActiveSupport::JSON.decode(d.to_json)).should != d
    @instance.parse_json_dates('2010-04-25T13:44:12Z').should == DateTime.new(2010, 4, 25, 13, 44, 12, 0).utc
  end
end
