require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe PersonCrewMember do  
  it "should reference a person" do
    r = PersonCrewMember.reflect_on_association :person
    r.class_name.should == "Person"
    r.macro.should == :belongs_to
  end
  
  it "should be immutable" do
    c = PersonCrewMember.new :flight => Factory.create(:flight)
    lambda {c.person = Factory.create(:person)}.should_not raise_error
    lambda {c.person = Factory.create(:person)}.should raise_error ImmutableObjectException
    lambda {c.update_attributes :person => Factory.create(:person)}.should raise_error ImmutableObjectException
  end
end
