require 'csv'

def upsert_financial_accounts(file)
  unmatched = []
  CSV.foreach(file, headers: true) do |line|
    account = FinancialAccount.where(name: line['name']).first
    if account
      account.update_attributes(Hash[line.select { |k,_| %(bank_account_holder bank_account_number bank_code).include?(k) }])
      account.update_attribute :number, line['number'] if line['number'] && !line['number'].blank?
      account.update_attribute :member_account, true
      puts account.to_s
      p line
    else
      unmatched << line
      account = FinancialAccount.create!(Hash[line.select { |k,_| %(number name bank_account_holder bank_account_number bank_code).include?(k) }])
      account.update_attribute :member_account, true
    end
  end
  unmatched
end
