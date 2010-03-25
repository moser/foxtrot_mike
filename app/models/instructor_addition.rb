module InstructorAddition
  def self.included(base) #:nodoc:
    base.acts_as_revisable :on_delete => :revise
  end
end
