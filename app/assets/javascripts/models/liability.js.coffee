class Flights.Models.Liability extends Flights.BaseModel
  paramRoot: 'liability'
  defaults:
    proportion: 1

  person: ->
    if @get("person_id")?
      Flights.people.get(@get("person_id"))

  flight: ->
    if @get("flight_id")?
      Flights.flights.get(@get("flight_id"))

  valid: ->
    @personValid() && @proportionValid()

  personValid: ->
    @person()?

  proportionValid: ->
    @get("proportion")? && @get("proportion") > 0

Flights.Collections.Liabilities  = Backbone.Collection.extend
  model: Flights.Models.Liability

  percentage_for: (liability) ->
    sum = _.reduce(@map((l) -> l.get("proportion")), ((m, e) -> m + e), 0)
    if sum > 0 then liability.get("proportion") / sum else 0
