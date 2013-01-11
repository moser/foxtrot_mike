F.Models.Person = Backbone.Model.extend
  paramRoot: 'person'
  present: ->
    F.Presenters.Person.present(@)

class F.Models.NoPerson
  constructor: ->
    @name = @id = "-"
    @firstname = @lastname = "0"
  present: ->
    @

class F.Models.NPersons extends F.Models.NoPerson
  constructor: (@n) ->
    @name = @id = "+#{@n}"
    @firstname = @lastname = @n
    

F.Collections.People = Backbone.Collection.extend
  model: F.Models.Person
  url: '/people'
