Flights.Models.Plane = Backbone.Model.extend
  paramRoot: 'plane'

Flights.Collections.Planes = Backbone.Collection.extend
  model: Flights.Models.Plane
  url: '/planes'
