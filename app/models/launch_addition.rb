module LaunchAddition
  def self.included(base) #:nodoc:
    base.has_paper_trail :meta => { :abstract_flight_id => Proc.new { |l| l.abstract_flight_id unless l.nil? || l.new_record? || l.abstract_flight_id.nil? } }
  end
end
