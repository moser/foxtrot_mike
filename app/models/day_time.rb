class DayTime
  attr_accessor :minutes
  def initialize(i)
    @minutes = i
  end
  
  def to_s
    unless @minutes < 0
      h, m = [@minutes / 60, @minutes % 60]
      "#{h < 10 ? "0" : ""}#{h}:#{m < 10 ? "0" : ""}#{m}"
    else
      "--:--"
    end
  end
  
  def method_missing(meth, *args, &block)
    @minutes.send(meth, *args, &block)
  end
end
