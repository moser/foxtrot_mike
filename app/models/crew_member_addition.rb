module CrewMemberAddition
  def self.included(base) #:nodoc:
    base.has_paper_trail :meta => { :abstract_flight_id => Proc.new { |cm| cm.abstract_flight_id unless cm.nil? || cm.new_record? || cm.abstract_flight_id.nil? } }
  end
end
