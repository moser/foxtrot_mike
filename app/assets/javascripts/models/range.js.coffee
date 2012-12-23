class Flights.Models.Range
  constructor: (@_from, @_to) ->

  from: ->
    @_from || @_to

  to: ->
    @_to || @_from

  toString: ->
    "#{Format.date_to_s(@from())}_#{Format.date_to_s(@to())}"

Flights.Models.Range.fromString = (str) ->
  new Flights.Models.Range(Parse.date_to_s(str.split("_")[0]), Parse.date_to_s(str.split("_")[1]))
