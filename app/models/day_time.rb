class DayTime
  attr_accessor :minutes
  def initialize(i)
    @minutes = i
  end

  def to_s
    if @minutes.nil?
      ""
    elsif @minutes >= 0
      h, m = [@minutes / 60, @minutes % 60]
      "#{h < 10 ? "0" : ""}#{h}:#{m < 10 ? "0" : ""}#{m}"
    else
      "--:--"
    end
  end

  def method_missing(meth, *args, &block)
    @minutes.send(meth, *args, &block)
  end

  def self.parse(str)
    if str =~ /^(\d+):(\d+)$/
      ($~[1].to_i * 60 + $~[2].to_i) % 1440
    elsif str =~ /^\d+$/
      str.to_i
    else
      -1
    end
  end
end
