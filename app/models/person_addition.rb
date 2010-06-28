module PersonAddition
  def self.included(base) #:nodoc:
    base.has_many :accounts
    base.has_paper_trail
  end
end
