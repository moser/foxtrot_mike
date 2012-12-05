class Flights.Models.WireLauncher extends Flights.BaseModel
  paramRoot: 'wire_launcher'

Flights.Collections.WireLaunchers = Backbone.Collection.extend
  model: Flights.Models.WireLauncher
  url: '/wire_launchers'
