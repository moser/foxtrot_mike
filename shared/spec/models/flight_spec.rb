require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Flight do
  before(:each) do
    @f = Flight.new
  end
  
  it { should have_many :liabilities }

  
  describe "liabilities_attributes" do
    
  end
  
  describe "cost" do    
    it "should calculate the values for liabilities" do
      @f.liabilities << Liability.new(:person => Person.generate, :proportion => 100)
      @f.save
      @f.should_receive(:cost).at_least(:once).and_return(stub("cost", :to_i => 400))
      @f.value_for(@f.liabilities.first).should == 400
      
      @f.liabilities << Liability.new(:person => Person.generate, :proportion => 100)
      @f.value_for(@f.liabilities.first).should == 200
    end
  end
  
  describe "shared_attributes" do 
    it "should contain liabilities_attributes" do
      @f.shared_attributes.keys.should include :liabilities_attributes
    end
  end
  
  describe "l" do
    it "should translate FLIGHT" do
      Flight.l.should == "Flight"
      Flight.l(:duration).should == "Duration"
    end
  end
end
