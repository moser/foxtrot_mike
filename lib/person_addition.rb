module PersonAddition
  def self.included(base) #:nodoc:
    base.has_many :accounts
    base.belongs_to :person_cost_category
    base.acts_as_revisable
  end
end
