identity = (v) -> v
class F.Models.SeveralFlights
  flights: []
  constructor: (flights) ->
    @flights = flights

  attributes:
    departure_date: (v) -> Format.date_to_s(v)
    plane: identity
    seat1_person: identity
    seat2_person: identity
    seat2_n: identity
    seat2: identity
    from: identity
    to: identity
    controller: identity
    cost_hint: identity

  possibleAttributes: ->
    if _.any(@flights, (f) -> f.get('is_tow'))
      _.without _.keys(@attributes), 'departure_date', 'from'
    else
      _.keys(@attributes)

  identicalAttributes: ->
    flights = @flights
    attrs = _.map @attributes, (t, a) ->
      { attr: a, values: _.map(flights, (f) -> t(f[a]())) }
    uniqAttrs = _.filter attrs, (a) ->
      _.uniq(a.values).length == 1
    _.map uniqAttrs, (a) -> a.attr

  identical: (attr) ->
    _.contains(@identicalAttributes(), attr)

  possible: (attr) ->
    _.contains(@possibleAttributes(), attr)

  get: (attr) ->
    @flights[0][attr]()
