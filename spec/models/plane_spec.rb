require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plane do   
  it "should be revisable" do
    Plane.new.should respond_to :versions
  end
end
