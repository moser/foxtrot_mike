module ValidityCheck
  # valid_from == nil <=> valid_from = -infinity
  # valid_to == nil <=> valid_to = infinity
  def valid_at?(time = Time.zone.now)
    time = time.to_date
    (valid_from.nil? || valid_from <= time) && (valid_to.nil? || time <= valid_to)
  end
  
  def not_valid_anymore_at?(time = Time.zone.now)
    time = time.to_date
    !valid_to.nil? && time > valid_to
  end
  
  def not_yet_valid_at?(time = Time.zone.now)
    time = time.to_date
    !valid_from.nil? && valid_from > time
  end

  def valid_at_booking_now?
    valid_at?(Booking.now)
  end

  def self.included(base)
    base.validates_presence_of :valid_from
    base.validates_each :valid_to do |record, attr, value|
      unless record.valid_from.nil? || record.valid_to.nil? || record.valid_from < record.valid_to
        record.errors.add(attr, :greater_than, { :count => (I18n.l(record.valid_from, :format => :short) rescue '') } )
      end
    end
  end
end
