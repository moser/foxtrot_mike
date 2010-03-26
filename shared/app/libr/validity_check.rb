module ValidityCheck
  # valid_from == nil <=> valid_from = -infinity
  # valid_to == nil <=> valid_to = infinity
  def valid_at?(time = Time.zone.now)
    (valid_from.nil? || valid_from <= time) && (valid_to.nil? || time <= valid_to)
  end
end
