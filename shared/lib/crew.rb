class Crew < ActiveRecord::Base
  has_one :flight
end
