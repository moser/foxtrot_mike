class Purpose
  attr_reader :str

  ALL = %w(training exercise tow)

  def initialize(s)
    @str = s
  end

  def to_s
    if @str
      I18n.t("activerecord.attributes.flight.purposes.#{@str}.long")
    else
      ""
    end
  end

  def short
   if @str
      I18n.t("activerecord.attributes.flight.purposes.#{@str}.short")
    else
      ""
    end
  end

  def self.all
    ALL.map { |p| Purpose.new(p) }
  end

  def info
    " "
  end

  def id
    str
  end

  def ==(that)
    if that.is_a?(String)
      id == that
    else
      id == that.id #TODO why warning?
    end
  end
end
