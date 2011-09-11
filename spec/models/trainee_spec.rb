require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Trainee do
  it "should return true for trainee?" do
    Trainee.new.trainee?.should be_true
  end

  it "should only be PIC(US) if no instructor is present" do
    t = Person.generate!
    t.should_receive(:trainee?).and_return(true)
    i = Person.generate!
    i.should_receive(:instructor?).and_return(true)
    f = Flight.generate! :seat1 => t
    f.seat1.pic?.should be_true
    f.seat1.picus?.should be_true
    f.seat2 = i
    f.seat1.reload
    f.seat1.pic?.should be_false
  end
end
