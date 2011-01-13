require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Purpose do
  it "should have a private constructor" do
    lambda { Purpose.new("tow") }.should raise_error
  end
  
  it "should cache objects" do
    Purpose.get("tow").object_id .should == Purpose.get("tow").object_id
  end
  
  it "should delegate to I18n to get long strings" do
    I18n.should_receive(:t).with(/tow\.long/)
    Purpose.get("tow").to_s
  end
  
  it "should delegate to I18n to get short strings" do
    I18n.should_receive(:t).with(/tow\.short/)
    Purpose.get("tow").short
  end
end
