class DestatisAirtrafficStats
  attr_reader :flights, :airfield

  MAPPING = { 'Echo' => [ 'Echo' ],
              'Glider' => [ 'Kilo (SFL)', 'Segelflugzeuge' ],
              'Kilo' => [ 'Kilo (TMG)' ],
              'UL' => [ 'UL' ] }

  def initialize(flights, airfield)
    @flights, @airfield = flights.where(from_id: airfield.id).to_a, airfield
  end

  def echo_training
    flights = training_flights(flights_of('Echo'))
    { p: local_flights(flights).count,
      s: cross_country_flights(flights).count }
  end

  def echo_rest
    flights = non_training_flights(flights_of('Echo'))
    { p: local_flights(flights).count,
      s: cross_country_flights(flights).count }
  end

  def gliders
    flights = flights_of('Glider')
    { all: flights.count,
      training: training_flights(flights).count,
      towed: flights.select { |f| f.tow_launch? }.count }
  end

  def motor_gliders
    flights = flights_of('Kilo')
    { all: flights.count,
      towed:  flights.select { |f| f.tow_launch? }.count }
  end

  def ultra_light
    flights = flights_of('UL')
    { all: flights.count,
      towed:  flights.select { |f| f.tow_launch? }.count }
  end

private
  def local_flights(flights)
    flights.select { |f| f.from_id == f.to_id }
  end

  def cross_country_flights(flights)
    flights.select { |f| f.from_id != f.to_id }
  end

  def non_training_flights(flights)
    flights.select { |f| f.purpose != :training }
  end

  def training_flights(flights)
    flights.select { |f| f.purpose == :training }
  end

  def tow_flights(flights)
    flights.select { |f| f.is_a? TowFlight }
  end

  def classes(key)
    MAPPING[key].map { |name| LegalPlaneClass.where(name: name).first }
  end

  def flights_of(class_key)
    classes = classes(class_key)
    self.flights.select { |f| classes.include?(f.plane.legal_plane_class) }
  end
end
