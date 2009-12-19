require File.dirname(__FILE__) + '/../spec_helper'

describe "soft validation" do 
  it "should add some class methods" do
    klass = Class.new do
      include SoftValidation::Validation
    end
    klass.should respond_to :soft_validations
    klass.should respond_to :soft_validate
    klass.should respond_to :soft_validates_presence_of
  end
  
  it "should add some instance methods" do
    klass = Class.new do
      include SoftValidation::Validation
    end
    instance = klass.new
    instance.should respond_to :soft_validate
    instance.should respond_to :problems
  end
  
  describe "class method soft_validate" do
    it "should add a validation" do
      klass = Class.new do
        include SoftValidation::Validation
      end
      klass.soft_validations.size.should == 0
      klass.soft_validate(1) { |i| }
      klass.soft_validations.size.should == 1
    end
  end
  
  describe "instance method soft_validate" do
    it "should call every soft validation" do
      called = false
      klass = Class.new do
        include SoftValidation::Validation
        soft_validate(1) { called = true }
      end
      klass.new.soft_validate
      called.should == true
    end
    
    it "should call only soft validation with severity above the threshold" do
      klass = Class.new do
        include SoftValidation::Validation
        soft_validates_presence_of 1, :a
        attr_accessor :a
      end
      instance = klass.new
      instance.soft_validate(2).should == true
    end
  end
  
  describe "soft_validates_presence_of" do
    it "should create a validation that generates a problem if attribute is nil" do
      klass = Class.new do
        include SoftValidation::Validation
        soft_validates_presence_of 1, :a
        attr_accessor :a
      end
      instance = klass.new
      instance.soft_validate.should == false
      instance.problems[:a].should_not be_nil
      instance.a = "foo"
      instance.soft_validate.should == true
      instance.problems[:a].should be_nil
    end
  end
  
end
