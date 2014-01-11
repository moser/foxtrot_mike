class TrainingStatistics
  attr_reader :flights, :legal_plane_class

  def initialize(flights, legal_plane_class)
    @flights = flights
    @legal_plane_class = legal_plane_class
  end

  def trainees
    training_flights.map(&:seat1_person).uniq.sort_by(&:name)
  end

  def instructors
    training_flights.map(&:seat2_person).compact.uniq.sort_by(&:name)
  end

  def instructor_flight_count(instructor)
    training_flights.select do |flight|
      flight.seat2_person == instructor
    end.count
  end

  def training_flights
    flights.select do |flight|
      flight.plane.legal_plane_class == legal_plane_class && flight.purpose == :training
    end
  end

  def wire_launch_count
    training_flights.select do |flight|
      flight.launch_type == 'WireLaunch'
    end.count
  end

  def tow_launch_count
    training_flights.select do |flight|
      flight.launch_type == 'AbstractFlight'
    end.count
  end

  def self_launch_count 
    training_flights.select do |flight|
      flight.launch_type.nil?
    end.count
  end

  def flight_time
    training_flights.map(&:duration).sum
  end
end
