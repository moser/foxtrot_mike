require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PersonCostCategoryMembership do
  before(:each) do
    @valid_attributes = {
      :valid_from => 1.day.ago,
      :person => Person.generate!,
      :person_cost_category => PersonCostCategory.generate!
    }
  end

  it "should create a new instance given valid attributes" do
    PersonCostCategoryMembership.create!(@valid_attributes)
  end

  it { should belong_to :person_cost_category }
  it { should belong_to :person }
  
  it { should ensure_immutability_of(:person) }
  it { should ensure_immutability_of(:person_cost_category) }
  
  it { should validate_presence_of :person_cost_category }
  it { should validate_presence_of :person }

  
  it "should find concerned accounting entry owners" do
    m = PersonCostCategoryMembership.create!(@valid_attributes)
    rel = mock("relation")
    rel.should_receive(:between).with(m.valid_from, nil)
    p = mock("person")
    p.should_receive("find_concerned_accounting_entry_owners").and_yield(rel)
    m.should_receive(:person).and_return(p)
    m.find_concerned_accounting_entry_owners { |r| r }
  end
end
