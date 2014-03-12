require 'spec_helper'

describe FinancialAccount do
  it { should have_many :financial_account_ownerships }

  it "should return name on to_s" do
    f = FinancialAccount.generate!(:name => "lala", :number => 123)
    f.to_s.should == "123 (lala)"
  end

  describe "#max_debit_value_f" do
    it "set the real value" do
      f = FinancialAccount.generate!
      f.max_debit_value_f = 100
      f.max_debit_value.should == 10000
    end

    it "returns a float value" do
      f = FinancialAccount.generate!
      f.max_debit_value = 101
      f.max_debit_value_f.should == 1.01
    end
  end

  describe '#kto_blz_to_iban' do
    subject { FinancialAccount.new(bank_account_number: '2209311', bank_code: '74221170') }

    it 'should generate an IBAN' do
      subject.kto_blz_to_iban.should == 'DE05742211700002209311'
    end
  end

  describe "#sequence_type" do
    context 'with no bank debits at all' do
      subject { FinancialAccount.generate!(first_debit_accounting_session_id: nil) }
      it "returns FRST for the first direct debit" do
        subject.sequence_type(nil).should == 'FRST'
      end
    end

    context 'with a session' do
      let(:first) { AccountingSession.generate! }
      subject { FinancialAccount.generate!(first_debit_accounting_session_id: first.id) }
      it "returns RCUR for the second direct debit" do
        subject.sequence_type(nil).should == 'RCUR'
        subject.sequence_type(first).should == 'FRST'
      end
    end
  end

  describe '#before_save' do
    context 'when iban, bic or mandate_id were changed' do
      subject { FinancialAccount.generate!(first_debit_accounting_session_id: AccountingSession.generate.id) }
      it 'resets the first_debit_accounting_session_id to nil' do
        subject.update_attribute :iban, ''
        subject.first_debit_accounting_session_id.should be_nil
      end
    end
  end
end
