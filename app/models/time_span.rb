class TimeSpan
  attr_accessor :minutes

  def initialize(i)
    @minutes = i 
  end
  
  def to_s
    unless @minutes.nil? || @minutes < 0
      h, m = [@minutes / 60, @minutes % 60]
      "#{h}:#{m < 10 ? "0" : ""}#{m}"
    else
      "-"
    end
  end
end