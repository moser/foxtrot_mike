Flights.Models.Person = Backbone.Model.extend
  paramRoot: 'person'
  present: ->
    Flights.Presenters.Person.present(@)

class Flights.Models.NoPerson
  constructor: ->
    @name = @id = "-"
    @firstname = @lastname = "0"
  present: ->
    @

class Flights.Models.NPersons extends Flights.Models.NoPerson
  constructor: (@n) ->
    @name = @id = "+#{@n}"
    @firstname = @lastname = @n
    

Flights.Collections.People = Backbone.Collection.extend
  model: Flights.Models.Person
  url: '/people'
