class Group < ActiveRecord::Base
  has_many :people
  has_many :planes
  validates_presence_of :name

  default_scope order("name ASC")

  def to_s
    name
  end

  def info
    ''
  end

  def flights
    AbstractFlight.include_all.where("abstract_flights.id in (#{CrewMember.arel_table.join(Person.arel_table).
                               on(CrewMember.arel_table[:person_id].eq(Person.arel_table[:id])).
                               where(CrewMember.arel_table[:type].in(['Trainee', 'PilotInCommand', 'Instructor'])).
                               where(Person.arel_table[:group_id].eq(self.id)).
                               project(CrewMember.arel_table[:abstract_flight_id]).to_sql})")
  end

  def to_j
    { :id => id, :name => name }
  end
end
