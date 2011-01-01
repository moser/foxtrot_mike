class DayTime
  attr_accessor :minutes
  def initialize(i)
    @minutes = i
  end
  
  def to_s
    unless @minutes.nil?
      h, m = [@minutes / 60, @minutes % 60]
      "#{h < 10 ? "0" : ""}#{h}:#{m < 10 ? "0" : ""}#{m}"
    else
      "--:--"
    end
  end
end