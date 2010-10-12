class Group < ActiveRecord::Base
  has_many :people
  has_many :planes

  validates_presence_of :name
  
  def to_s
    name
  end

  def info
    ''
  end
end
