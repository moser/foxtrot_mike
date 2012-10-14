Flights.Models.Airfield = Backbone.Model.extend
  paramRoot: 'airfield'

Flights.Collections.Airfields = Backbone.Collection.extend
  model: Flights.Models.Airfield
  url: '/airfields'
