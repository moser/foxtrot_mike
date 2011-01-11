module ImmutableFlight
  def self.included(klass)
    klass.before_save :check_editability
    klass.extend ClassMethods
#TODO spec and activate
    klass.validate do |f|
      errors.add(self.class.flight_relation, I18n.t("activerecord.errors.not_editable")) unless f.send(self.class.flight_relation).nil? || f.send(self.class.flight_relation).editable?
    end
  end

  module ClassMethods
    def flight_relation(n = nil)
      @flight_relation = (n || @flight_relation || :abstract_flight)
    end
  end

  def check_editability
    send(self.class.flight_relation).nil? || send(self.class.flight_relation).editable?
  end
end
