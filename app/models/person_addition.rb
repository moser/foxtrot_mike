module PersonAddition
  def self.included(base) #:nodoc:
    base.has_many :accounts
    base.acts_as_revisable :on_delete => :revise
  end
end
