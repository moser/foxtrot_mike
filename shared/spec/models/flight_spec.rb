require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

describe Flight do
  before(:each) do
    @f = Flight.new
  end
  
  it { should have_many :liabilities }

  describe "liabilities" do
    it "should create a default liability if none other present" do
      f = Flight.create(:seat1 => Person.generate)
      f.liabilities_with_default.count.should == 1
    end
  end
  
  describe "liabilities_attributes" do
    it "TODO"
  end
  
  describe "cost" do    
    it "should calculate the values for liabilities" do
      @f.save
      @f.liabilities.create(:person => Person.generate, :proportion => 100)
      @f.should_receive(:cost).at_least(:once).and_return(stub("cost", :sum => 400))
      p @f.liabilities.first
      @f.proportion_for(@f.liabilities.first).should == 1.0
      @f.value_for(@f.liabilities.first).should == 400
      
      @f.liabilities << Liability.new(:person => Person.generate, :proportion => 100)
      @f.proportion_for(@f.liabilities.first).should == 0.5
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
