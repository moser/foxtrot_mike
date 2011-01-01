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

  def to_crew_member_types
    if instructor?
      [ PilotInCommand, Instructor ]
    elsif trainee?
      [ Trainee ]
    else
      [ PilotInCommand ]
    end    
  end

  def editable?
    new_record? || flights.empty?
  end

  def flights
    AbstractFlight.include_all.where(AbstractFlight.arel_table[:departure].gteq(valid_from).
                             and(AbstractFlight.arel_table[:departure].lteq(valid_to || 1.day.from_now.to_date))).
           joins(:crew_members).
           where('crew_members.type' => to_crew_member_types.map(&:to_s), 
                 'crew_members.person_id' => person_id).joins(:plane).
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
end
