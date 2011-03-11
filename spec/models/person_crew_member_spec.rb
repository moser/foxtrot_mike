require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PersonCrewMember do  
  it { should belong_to :person }
  it { should validate_presence_of :person }
  it { should ensure_immutability_of(:person) }
  
  it "should respond to to_s" do
    c = PersonCrewMember.new
    c.stub(:person => stub("person", :to_s => "aaa"))
    c.to_s.should == "aaa"
  end

  it "value should return a person" do
    m = PersonCrewMember.create :person => person = Person.generate!
    m.value.should == person
  end
end
