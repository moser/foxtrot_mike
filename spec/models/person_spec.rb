require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do  
  it { should have_many :financial_account_ownerships }
  it { should validate_presence_of :financial_account }
  
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
    Person.generate!.flights
  end
end
