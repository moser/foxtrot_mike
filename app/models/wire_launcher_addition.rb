module WireLauncherAddition
  def self.included(base) #:nodoc:
    base.belongs_to :financial_account
    base.has_paper_trail
  end
end
