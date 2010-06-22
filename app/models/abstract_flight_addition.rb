module AbstractFlightAddition  
  def self.included(base) #:nodoc:
    base.acts_as_revisable :on_delete => :revise
    base.send(:include, SoftValidation::Validation)
    base.soft_validates_presence_of 1, :duration
    base.soft_validates_presence_of 1, :departure
    base.soft_validate 1 do |r|
      r.problems['crew_members'] = 'No Crew specified' if r.crew_members.size == 0
    end
  end
end
