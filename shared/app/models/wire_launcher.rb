class WireLauncher < ActiveRecord::Base
  include UuidHelper
  has_many :wire_launcher_cost_category_memberships
end
