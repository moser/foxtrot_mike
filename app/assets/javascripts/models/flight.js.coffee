class Flights.Models.Flight extends Flights.BaseModel
  paramRoot: 'flight'
  defaults:
    departure_date: new Date()
    purpose: "training"
    departure_i: -1
    arrival_i: -1
    comment: ""
    is_tow: false

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

  launch_type: ->
    if @get("launch")?
      switch @get("launch").type
        when "TowFlight"
          "tow_launch"
        when "WireLaunch"
          "wire_launch"
    else
      "self_launch"

  launch: ->
    unless @ilaunch? && @get("launch")?
      if @launch_type() == "tow_launch"
        @ilaunch = Flights.flights.get(@get("launch").id) || new Flights.Models.Flight(@get("launch"))
      else if @launch_type() == "wire_launch"
        @ilaunch = new Flights.Models.WireLaunch(@get("launch"))
    @ilaunch

  change_launch_type: (launch_type) ->
    @ilaunch = null
    if launch_type == "tow_launch"
      @ilaunch = new Flights.Models.Flight({ from_id: @get("from_id"), to_id: @get("from_id"), departure_i: @get("departure_i"), type: "TowFlight", is_tow: true})
    else if launch_type == "wire_launch"
      @ilaunch = new Flights.Models.WireLaunch({ type: "WireLaunch" })
    @set("launch", if @ilaunch? then @ilaunch.toJSON() else null)
    

  dirty: ->
    super() || (@launch()? && @launch().dirty())

  reset: ->
    super()
    @ilaunch = null
    @launch()

  save: ->
    #set liabilities
    @save_launch()
    super {},
      success: =>
        @ilaunch = null
        if @launch_type() == "tow_launch"
          unless Flights.flights.get(@launch().id)?
            Flights.flights.add(@launch())
          @launch().fetch()
        f = Flights.flights.find((f) => f.get("abstract_flight_id") == @id)
        f.fetch() if f?

  fetch: ->
    super
      error: (m, x, o) =>
        if x.status == 404
          Flights.flights.remove(m)

  save_launch: ->
    if @launch_type() == "tow_launch" || @launch_type() == "wire_launch"
      @set("launch_attributes", @launch().toJSON())
    else
      @set("launch_attributes", "none")

  initialize: ->
    super()
    


Flights.Collections.Flights = Backbone.Collection.extend
  model: Flights.Models.Flight
  url: '/flights'
