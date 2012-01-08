class ControllerLog
  attr_accessor :controllers
  NoController = Struct.new("NoController", :name)

  def initialize(airfield, date)
    @no = NoController.new(I18n.t("views.no_controller"))
    @controllers = []
    @airfield = airfield
    flights = airfield.flights.where(:departure_date => date).order("departure_i ASC")
    flights.each do |f|
      unless f.departure_i < 0
        @controllers << { :person => f.controller || @no, :from => from(f) }
      end
    end
    found = true
    while found do
      found = false
      for i in (0..(@controllers.count - 2))
        if @controllers[i][:from] == @controllers[i + 1][:from]
          found = true
          @controllers[i][:person] = prefer_person(@controllers[i][:person], @controllers[i+1][:person])
          @controllers.delete_at(i+1)
          break
        end
      end
    end
    found = true
    while found do
      found = false
      for i in (0..(@controllers.count - 2))
        if @controllers[i][:person] == @controllers[i+1][:person]
          @controllers.delete_at(i)
          found = true
          break
        end
      end
    end
    for i in (0..(@controllers.count - 2))
      @controllers[i][:to] = @controllers[i + 1][:from]
    end
    if @controllers.count > 0
      @controllers.last[:to] = flights.last.arrival_i || @airfield.srss.sunset_i(@date)
    end
  end

  def merge(from, to)
    i = 0
    from.each do |f|
      puts i
      p controllers[i]
      @controllers[i][:from] = DayTime.parse(f)
      i += 1
    end
    i = 0
    to.each do |f|
      @controllers[i][:to] = DayTime.parse(f)
      i += 1
    end
  end

  private
  def prefer_person(a, b)
    if Person === a || !(Person === b)
      p [a.to_s, b.to_s, a.to_s]
      a
    else
      p [a.to_s, b.to_s, b.to_s]
      b
    end
  end

  def from(f)
    if f.from == @airfield
      f.departure_i
    else
      f.arrival_i
    end
  end
end
