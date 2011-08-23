require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DayTime do  
  it "should format the time" do
    DayTime.new(0).to_s.should == "00:00"
    DayTime.new(1).to_s.should == "00:01"
    DayTime.new(59).to_s.should == "00:59"
    DayTime.new(60).to_s.should == "01:00"
  end
  
  it "should show --:-- for unset time" do
    DayTime.new(-1).to_s.should == "--:--"
  end
end
