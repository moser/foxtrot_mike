# TimeCostRule: personcc, planecc, flight_type (Flight|TowFlight), depends_on (duration|engine_duration), cost
# WireLaunchCostRule: personcc, wirelaunchercc, cost
# TowCostRule: personcc, planecc, level (e.g. 300m, 500m, 1000m), cost 

class CostRule < ActiveRecord::Base
end
