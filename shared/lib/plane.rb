class Plane < ActiveRecord::Base
  #server side
  if RAILS_ENV
    acts_as_revisable
    belongs_to :plane_cost_category
  end

  has_many :flights
end
