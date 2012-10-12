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
    AbstractFlight.include_all.
      joins(:seat1_person).
      joins("INNER JOIN groups ON groups.id =  people.group_id").
      where("groups.id = 1")
  end

  def to_j
    { :id => id, :name => name }
  end
end
