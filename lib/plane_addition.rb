module PlaneAddition
  def self.included(base) #:nodoc:
    base.belongs_to :plane_cost_category
    base.acts_as_revisable :on_delete => :revise
  end
end
