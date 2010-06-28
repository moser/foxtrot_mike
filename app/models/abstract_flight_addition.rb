module AbstractFlightAddition  
  def self.included(base) #:nodoc:
    base.has_paper_trail # :meta => { :abstract_flight_id => Proc.new { |flight| flight.id } }
    base.send(:include, SoftValidation::Validation)
    base.soft_validates_presence_of 1, :duration
    base.soft_validates_presence_of 1, :departure
    base.soft_validate 1 do |r|
      r.problems['crew_members'] = 'No Crew specified' if r.crew_members.size == 0
    end
  end
  
  def all_versions
    (versions + Version.where(:abstract_flight_id => id)).sort_by { |e| e.created_at }
  end
  
  def all_changes
    all_versions.select { |version| version.event != "create" }
  end
end
