module LiabilityAddition
  def self.included(base) #:nodoc:
    base.has_paper_trail :meta => { :abstract_flight_id => Proc.new { |l| l.flight_id unless l.nil? || l.new_record? || l.flight_id.nil? } }
  end
end
