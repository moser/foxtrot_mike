class Purpose
  attr_reader :str
  private_class_method :new

  ALL = %w(training exercise tow)
  
  def self.get(str)
    @all ||= {}
    @all[str] ||= new(str)
  end

  def initialize(s)
    @str = s
  end

  def to_s
    if @str
      I18n.t("flight.purposes.#{@str}.long")
    else
      ""
    end
  end

  def short
   if @str
      I18n.t("flight.purposes.#{@str}.short")
    else
      ""
    end
  end

  def self.all
    ALL.map { |p| Purpose.get(p) }
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
