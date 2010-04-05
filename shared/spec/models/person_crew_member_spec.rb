require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe PersonCrewMember do  
  it { should belong_to :person }
  
  it "should be immutable" do
    c = PersonCrewMember.new :flight => Flight.generate!
    lambda {c.person = Person.generate!}.should_not raise_error
    lambda {c.person = Person.generate!}.should raise_error ImmutableObjectException
    lambda {c.update_attributes :person => Person.generate!}.should raise_error ImmutableObjectException
  end
end
