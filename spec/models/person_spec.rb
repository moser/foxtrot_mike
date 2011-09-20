require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do  
  it { should have_many :financial_account_ownerships }
  it { should have_many :wire_launches }
  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :group }
  
  it "should have one current financial_account_ownership" do
    p = Person.new
    p.should respond_to(:current_financial_account_ownership)
    m = mock("ownership")
    m.should_receive(:financial_account).at_least(:once).and_return(1)
    p.should_receive(:current_financial_account_ownership).at_least(:once).and_return(m)
    p.financial_account.should == 1
  end
  
  it "should find people by their name" do
    martin = Person.generate!(:lastname => "Foo", :firstname => "Martin")
    tom = Person.generate!(:lastname => "Foo", :firstname => "Tom")
    Person.find_by_name('foo').should == nil
    Person.find_by_name('martin').should == martin
    Person.find_by_name('martin f').should == martin
    Person.find_by_name('FOO M').should == martin
  end
  
  it "should find all people by their name" do
    Person.destroy_all
    martin = Person.generate!(:lastname => "Foo", :firstname => "Martin")
    tom = Person.generate!(:lastname => "Foo", :firstname => "Tom")
    Person.find_all_by_name('foo').should == [martin, tom]
    Person.find_all_by_name('martin').should == [martin]
    Person.find_all_by_name('martin f').should == [martin]
    Person.find_all_by_name('FOO M').should == [martin]
  end
  
  it "should have many person cost category memberships" do
    r = Person.reflect_on_association :person_cost_category_memberships
    r.class_name.should == "PersonCostCategoryMembership"
    r.macro.should == :has_many
  end
  
  it "should be revisable" do
    Person.new.should respond_to :versions
  end

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
    p = Person.generate!
    f = Flight.generate! :seat1 => p
    p.flights.should include(f)
  end
  
  it "should return flights a person is liable for" do
    p = Person.generate!
    f = Flight.generate!
    f2 = Flight.generate!
    f.liabilities.create :person => p, :proportion => 1
    p.flights_liable_for.should include(f)
    p.flights_liable_for.should_not include(f2)
  end
  
  it "should find concerned accounting entry owners" do
    m = mock("make sure the block is executed")
    m.should_receive(:lala).twice
    p = Person.create
    p.should_receive("flights").with(any_args).and_return([1])
    p.should_receive("flights_liable_for").and_return([2])
    p.find_concerned_accounting_entry_owners { |r| m.lala; r }.should include(1, 2)
  end
  
  it "should not include tow flights in " do
    p = Person.generate!
    f = TowFlight.generate! :seat1_id => p
    p.reload
    p.find_concerned_accounting_entry_owners.should_not include(f)
  end
  it "should include license information in custom json return by to_j" do
    p = Person.generate!
    l = License.generate! :person => p
    p.reload

    p.licenses.each { |e| e.should_receive(:to_j) }
    p.to_j.keys.should include(:licenses, :id, :firstname, :lastname, :group_id, :group_name)
  end
end
