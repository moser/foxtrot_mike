require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CrewMember do  
  it { should belong_to :abstract_flight }
  it { should ensure_immutability_of(:abstract_flight, lambda { Flight.generate! }) }
  it "should respond to some helpful methods" do
    c = CrewMember.new
    [ :size, :trainee?, :instructor?, :pic?, :picus? ].each do |e|
      c.should respond_to(e)
    end
  end
end
