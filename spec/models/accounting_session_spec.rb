require 'spec_helper'

describe AccountingSession do
  it { should have_many :accounting_entries }
  it { should validate_presence_of :name }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :end_date }
  it { should_not allow_value(5.days.from_now).for(:end_date) }

  context '#negative_financial_accounts' do
    xit 'finds accounts with bank_account_number or iban set'
  end

  it "should not be finished unless the finished_at date is present" do
    s = AccountingSession.new
    s.finished?.should be_false
    s.finished_at = 1.hour.ago
    s.finished?.should be_true
  end

  it "sets the first_debit_accounting_session_id on accounts" do
    d = FinancialAccount.generate!(member_account: true, iban: 'DE000000000000000000000', bic: 'CASFKL09238')
    c = FinancialAccount.generate!
    o = FinancialAccount.generate!
    a = AccountingSession.generate!
    a.accounting_entries_without_default.create(from: d, to: o, value: 1000, text: 'barr', manual: true)
    a.update_attribute(:finished_at, 1.day.ago)
    s = AccountingSession.new(debit_type: 'sepa', name: 'a', bank_debit: true, credit_financial_account: c, voucher_number: '1', accounting_date: 1.day.from_now)
    s.save!
    s.finished = true
    d.reload
    d.first_debit_accounting_session.should == s
  end

  it "should convert end_date to a date" do
    a = AccountingSession.new(:end_date => 5.days.ago)
    a.end_date.class.should == Date
  end

  it "should return the maximum of to dates for latest_session_end" do
    AccountingSession.destroy_all
    AccountingSession.generate!(:end_date => 3.days.ago)
    AccountingSession.generate!(:end_date => 1.days.ago)
    AccountingSession.latest_session_end.should == 1.day.ago.to_date
  end

  it "should return the maximum of to dates of finished sessions for latest_finished_session_end" do
    AccountingSession.destroy_all
    AccountingSession.generate!(:end_date => 3.days.ago, :finished_at => 2.days.ago)
    AccountingSession.generate!(:end_date => 1.days.ago)
    AccountingSession.latest_finished_session_end.should == 3.day.ago.to_date
  end

  it "should return the date before the first flight" do
    AccountingSession.destroy_all
    Flight.generate!(:departure => 2.years.ago)
    AccountingSession.latest_session_end.should == (AbstractFlight.oldest_departure.to_date - 1.day)
  end

  it "should have a sensible default for start_date" do
    AccountingSession.destroy_all
    d = AccountingSession.latest_session_end
    a = AccountingSession.generate!(:end_date => 5.days.ago)
    a.start_date.should == (d + 1.day)
    b = AccountingSession.generate!(:end_date => 3.days.ago)
    b.start_date.should == (a.end_date + 1.day)
  end

  it "should have a sensible default for end_date" do
    AccountingSession.destroy_all
    a = AccountingSession.generate!(:end_date => ((Date.today - 1.month).end_of_month))
    AccountingSession.new.end_date.should == Date.today.end_of_month
  end

  it "should pwn all flights between start and end date when finished" do
    AccountingSession.destroy_all
    f = Flight.generate!(:departure_date => 1.day.ago)
    s = AccountingSession.generate!(:start_date => 1.day.ago, :end_date => 1.day.ago)
    s.finished = true
    s.finished?.should be_true
    f.reload
    f.accounting_session.should == s
  end

  it "should create aggregated entries" do
    AccountingSession.destroy_all
    f = Flight.generate!(:departure_date => 1.day.ago)
    planecc = PlaneCostCategoryMembership.generate!(:plane => f.plane).plane_cost_category
    personcc = PersonCostCategoryMembership.generate!(:person => f.seat1_person).person_cost_category
    r = FlightCostRule.create!(:plane_cost_category => planecc, :person_cost_category => personcc, :valid_from => 2.days.ago, :flight_type => "Flight")
    r.flight_cost_items.create :depends_on => "duration", :value => 10
    f.reload
    s = AccountingSession.generate!(:start_date => 1.day.ago, :end_date => 1.day.ago)
    a = s.aggregated_entries.first
    a.from.should == f.seat1_person.financial_account
    a.to.should == f.plane.financial_account
  end

  it "should pwn all accounting entries when finished" do
    AccountingSession.destroy_all
    f = Flight.generate!(:departure_date => 1.day.ago)
    planecc = PlaneCostCategoryMembership.generate!(:plane => f.plane).plane_cost_category
    personcc = PersonCostCategoryMembership.generate!(:person => f.seat1_person).person_cost_category
    r = FlightCostRule.create!(:plane_cost_category => planecc, :person_cost_category => personcc, :valid_from => 2.days.ago, :flight_type => "Flight")
    r.flight_cost_items.create :depends_on => "duration", :value => 10
    f.reload
    f.calculate_cost_if_necessary
    s = AccountingSession.generate!(:start_date => 1.day.ago, :end_date => 1.day.ago)
    f.accounting_entries.map { |e| e.accounting_session == s }.should == [ false ]
    s.finished = true
    f.accounting_entries.map { |e| e.accounting_session == s }.should == [ true ]
  end

  it "should remove start and end dates when without_flights is true" do
    s = AccountingSession.generate!(:start_date => 1.day.ago, :end_date => 1.day.ago, :without_flights => true)
    s.start_date.should == nil
    s.end_date.should == nil
  end

  context "exclusions" do
    subject { s = AccountingSession.generate!(:start_date => 1.day.ago, :end_date => 1.day.ago, :bank_debit => true, credit_financial_account: FinancialAccount.generate!) }

    it "adds an excluded financial account id" do
      subject.add_excluded_account(fa = FinancialAccount.generate!)
      subject.reload

      subject.exclusions.count.should == 1
      subject.exclusions.should include(fa)
    end

    it "removes an excluded financial account" do
      subject.add_excluded_account(fa = FinancialAccount.generate!)
      subject.reload
      subject.remove_excluded_account(fa)
      subject.reload

      subject.exclusions.should_not include(fa)
    end
  end
end
