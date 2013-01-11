class F.Models.Range
  constructor: (@_from, @_to) ->

  from: ->
    @_from || @_to

  to: ->
    @_to || @_from

  toString: ->
    "#{Format.date_to_s(@from())}_#{Format.date_to_s(@to())}"

F.Models.Range.fromString = (str) ->
  new F.Models.Range(Parse.date_to_s(str.split("_")[0]), Parse.date_to_s(str.split("_")[1]))
