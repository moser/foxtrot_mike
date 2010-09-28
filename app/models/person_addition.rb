module PersonAddition
  def self.included(base) #:nodoc:
    base.has_many :accounts
    base.belongs_to :financial_account
    base.has_paper_trail
  end
end
