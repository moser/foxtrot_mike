require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Liability do  
  it { should belong_to :flight }
  it { should belong_to :person }

  it { should validate_presence_of :flight }
  it { should validate_presence_of :person }
  it { should validate_presence_of :proportion }

  it { should validate_numericality_of(:proportion) }
  
  it "should delegate value to flight" do
    l = Liability.new
    flight = mock("flight")
    flight.should_receive(:value_for).with(l)
    l.stub :flight => flight
    l.value
  end

  it "should validate that flight is editable before creation" do
    f = Factory.create(:non_editable_flight)

    l = f.liabilities.create(:person => Person.generate!, :proportion => 1)
    l.should be_new_record
    l.errors.should include(:flight)
    l = Liability.create(:person => Person.generate!, :proportion => 1, :flight => f)
    l.should be_new_record
    l.errors.should include(:flight)
  end

  it "should validate that flight is editable before save" do
    f = Flight.generate!
    l = f.liabilities.create(:person => Person.generate!, :proportion => 1)
    f.accounting_session = a = AccountingSession.generate!
    f.save
    a.update_attributes(:finished_at => 1.hour.ago)
    f = Flight.find(f.id)
    l.reload

    l.proportion = 5
    l.save.should be_false
  end
end
