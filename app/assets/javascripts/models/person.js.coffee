Flights.Models.Person = Backbone.Model.extend
  paramRoot: 'person'

Flights.Collections.People = Backbone.Collection.extend
  model: Flights.Models.Person
  url: '/people'
