require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Person do  
  it "should tell if she is a trainee" do
    p = Person.spawn
    p.trainee?(nil).should == false
  end
  
  it "should concat it's name" do
    p = Person.spawn
    p.name.should == "bar foo"
  end
  
  it "should match it's name" do
    p = Person.spawn
    p.name?("bar foo").should be_true
    p.name?("BAr fOO").should be_true
  end
  
  it "should return name when sent to_s" do
    p = Person.spawn
    p.to_s.should == "bar foo"
  end

  it "should be sortable" do
    Person.new.should respond_to :'<=>'
    a = Person.new(:firstname => "Foo", :lastname => "Bar")
    b = Person.new(:firstname => "Goo", :lastname => "Bar")
    c = Person.new(:firstname => "Aaa", :lastname => "Zar")
    [b, c, a].sort.should == [a, b, c]
  end
  
  it "should only shared some attributes" do
    Person.shared_attribute_names.should == [ :id, :lastname, :firstname, :birthdate, :email, :group_id ]
  end
  
  it "should return shared_attributes" do
    Person.generate!.shared_attributes.keys.to_set.should == Person.shared_attribute_names.map { |n| n.to_s }.to_set
  end

  it "should return a persons flights" do
    Person.generate!.flights
  end
end
