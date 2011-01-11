require File.dirname(__FILE__) + '/../spec_helper'

describe FlightsController do
  it "should only include the days in question when called with plus_days or minus_days" do
    xhr :get, :index, :day_parse_date => "2010-10-28", :minus_days => 10
    assigns[:days].keys.should_not include(Date.parse("2010-10-29"))
  end
  
end
