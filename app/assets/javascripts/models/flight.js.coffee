Flights.Models.Flight = Backbone.Model.extend
  paramRoot: 'flight'

  plane: ->
    if @get("plane_id")?
      Flights.planes.get(@get("plane_id"))

  seat1_person: ->
    if @get("seat1_person_id")?
      Flights.people.get(@get("seat1_person_id"))

  seat2_person: ->
    if @get("seat2_person_id")?
      Flights.people.get(@get("seat2_person_id"))

  controller: ->
    if @get("controller_id")?
      Flights.people.get(@get("controller_id"))

  from: ->
    if @get("from_id")?
      Flights.airfields.get(@get("from_id"))

  to: ->
    if @get("to_id")?
      Flights.airfields.get(@get("to_id"))

  duration: ->
    if @get("arrival_i") >= 0 && @get("departure_i") >= 0
      @get("arrival_i") - @get("departure_i")
    else
      -1

Flights.Collections.Flights = Backbone.Collection.extend
  model: Flights.Models.Flight
  url: '/flights'
