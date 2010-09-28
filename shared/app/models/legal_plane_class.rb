class LegalPlaneClass < ActiveRecord::Base
  has_many :planes
  has_and_belongs_to_many :licenses
  validates_presence_of :name

  def to_s
    name
  end
end
