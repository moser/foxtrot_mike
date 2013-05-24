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
    martin = Person.generate!(:lastname => "Foo", :firstname => "Martin")
    tom = Person.generate!(:lastname => "Foo", :firstname => "Tom")
    Person.find_all_by_name('foo').should == [ martin, tom]
    Person.find_all_by_name('martin').should == [martin]
    Person.find_all_by_name('martin f').should == [martin]
    Person.find_all_by_name('FOO M').should == [martin]
  end
  
  it "should have many person cost category memberships" do
    r = Person.reflect_on_association :person_cost_category_memberships
    r.class_name.should == "PersonCostCategoryMembership"
    r.macro.should == :has_many
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
  
  it "should return a persons flights" do
    p = Person.generate!
    f = Flight.generate! :seat1_person => p
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
    f = TowFlight.generate! :seat1_person => p
    p.reload
    p.find_concerned_accounting_entry_owners.should_not include(f)
  end

  describe "#lvb_member_state" do
    it "should return a key representing the member state for LVB" do
      p = Person.spawn :birthdate => 9.years.ago, :member_state => :active, :primary_member => true
      p.lvb_member_state.should == :young_children
      p.lvb_member_state(2.years.from_now).should == :children
      p.birthdate = 10.years.ago - 1.day
      p.lvb_member_state.should == :children
      p.birthdate = 14.years.ago - 1.day
      p.lvb_member_state.should == :youths
      p.birthdate = 22.years.ago - 1.day
      p.lvb_member_state.should == :adults
    end
  end

  describe "#active?" do
    it "should return true if the member_state is active" do
      p = Person.spawn :member_state => :active
      p.active?.should be_true
      p.member_state = :passive
      p.active?.should be_false
    end
  end

  describe "#donor?" do
    it "should return true if the member_state is donor" do
      p = Person.spawn :member_state => :donor
      p.donor?.should be_true
      p.member_state = :passive
      p.donor?.should be_false
    end
  end

  describe "#passive?" do
    it "should return true if the member_state is passive" do
      p = Person.spawn :member_state => :passive
      p.passive?.should be_true
      p.member_state = :passive_with_voting_right
      p.passive?.should be_true
      p.member_state = :active
      p.passive?.should be_false
    end
  end

  describe "#passive_with_voting_right?" do
    it "should return true if the member_state is passive_with_voting_right" do
      p = Person.spawn :member_state => :passive_with_voting_right
      p.passive?.should be_true
      p.member_state = :active
      p.passive?.should be_false
    end
  end

  describe "#age_at" do
    it "should return the age in years" do
      p = Person.spawn :birthdate => 20.years.ago.to_date
      p.age_at(1.day.ago).should == 19
      p.age_at(Date.today).should == 20
      p.age_at(1.day.from_now).should == 20
      p.age_at(400.days.from_now).should == 21
      p.birthdate = 10.years.ago.to_date
      p.age.should == 10
    end
  end

  describe ".import" do
    it 'imports people from an array of hashes' do
      group = Group.generate!
      hashes = [
        { firstname: 'foo', lastname: 'bar', group_id: group.id },
        { firstname: 'MOOOOOO', lastname: 'cow', group_id: group.id }
      ]
      Person.import(hashes)
      hashes.each do |hash|
        Person.where(hash).count.should == 1
      end
    end

    it 'creates a group if necessary' do
      hashes = [
        { firstname: 'foo', lastname: 'bar', group: 'Club' },
        { firstname: 'MOOOOOO', lastname: 'cow', group: 'Club' }
      ]
      Person.import(hashes)
      Group.where(name: 'Club').count.should == 1
    end

    it 'creates financial_account_owner_ships' do
      fa = FinancialAccount.generate!
      group = Group.generate!
      hashes = [
        { firstname: 'foo', lastname: 'bar', financial_account_id: fa.id, group_id: group.id }
      ]
      Person.import(hashes)
      Person.where(firstname: 'foo', lastname: 'bar').first.financial_account.should == fa
    end

    it 'creates an financial account' do
      group = Group.generate!
      hashes = [
        { firstname: 'foo',
          lastname: 'bar',
          financial_account_number: '123',
          financial_account_name: 'foo',
          financial_account_bank_account_holder: 'foo bar',
          financial_account_bank_account_number: '11111',
          financial_account_bank_code: '22222',
          financial_account_member_account: '1',
          financial_account_advance_payment: '0',
          group_id: group.id }
      ]
      Person.import(hashes)
      fa = Person.where(firstname: 'foo', lastname: 'bar').first.financial_account
      fa.number.should == '123'
      fa.name.should == 'foo'
      fa.bank_account_holder.should == 'foo bar'
      fa.bank_account_number.should == '11111'
      fa.bank_code.should == '22222'
      fa.member_account.should be_true
      fa.advance_payment.should be_false
    end

    it 'creates person_category_membership' do
      pc = PersonCostCategory.generate!(name: 'asdf')
      group = Group.generate!
      hashes = [
        { firstname: 'foo', lastname: 'bar', person_cost_category: 'asdf', group_id: group.id }
      ]
      Person.import(hashes)
      Person.where(firstname: 'foo', lastname: 'bar').first.person_cost_category_memberships_at(Date.today).map(&:person_cost_category).should == [pc]
    end
  end
end
