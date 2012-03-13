class LegalPlaneClass < ActiveRecord::Base
  has_many :planes
  has_and_belongs_to_many :licenses
  validates_presence_of :name

  default_scope order("name ASC")

  def to_s
    name
  end

  def to_j
    { :id => id, :name => name }
  end
end
