class License < ActiveRecord::Base
  Levels = ['trainee', 'normal', 'instructor']
  belongs_to :person
  has_and_belongs_to_many :legal_plane_classes
  include ValidityCheck
  validates_inclusion_of :level, :in => Levels
  validates_presence_of :person, :name, :level

  def instructor?
    level == "instructor"
  end

  def trainee?
    level == "trainee"
  end

  def editable?
    new_record? || flights.empty?
  end

  def flights
    AbstractFlight.where(AbstractFlight.arel_table[:departure_date].gteq(valid_from).
                             and(AbstractFlight.arel_table[:departure_date].lteq(valid_to || 1.day.from_now.to_date))).
           where('abstract_flights.seat1_person_id = ? OR abstract_flights.seat2_person_id = ?', person_id, person_id).joins(:plane).
           where('planes.legal_plane_class_id' => legal_plane_class_ids)
  end

  def <=>(other)
    name <=> other.name
  end

  def to_s
    "#{person.name} #{name}"
  end

  def info
    "#{level}"
  end

  def to_j
    { :name => name, :level => level, :legal_plane_class_ids => legal_plane_class_ids, :valid_from => valid_from, :valid_to => valid_to }
  end
end
