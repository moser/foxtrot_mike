class WireLauncher < ActiveRecord::Base
  include UuidHelper
  include Membership
  include Current
  include AccountingEntryInvalidation
  
  has_paper_trail

  has_many :wire_launcher_cost_category_memberships
  membership :wire_launcher_cost_category_memberships
  has_many :wire_launches
  has_many :financial_account_ownerships, :as => :owner, :after_add => :association_changed, :after_remove => :association_changed
  has_one_current :financial_account_ownership

  validates_presence_of :registration, :financial_account
  
  def financial_account
    current_financial_account_ownership && current_financial_account_ownership.financial_account
  end
  
  def financial_account=(fa)
    if new_record?
      financial_account_ownerships << FinancialAccountOwnership.create(:financial_account => fa, :owner => self)
    end
  end
  
  def financial_account_id
    financial_account && financial_account.id
  end
  
  def financial_account_id=(fa)
    self.financial_account = FinancialAccount.find(fa)
  end
  
  def to_s
    registration
  end
  
  def find_concerned_accounting_entry_owners(&blk)
    blk ||= lambda { |r| r }
    blk.call(wire_launches)
  end

  def to_j
    { :id => id, :registration => registration }
  end
private
  def association_changed(obj = nil)
    delay.invalidate_concerned_accounting_entries
  end
end
