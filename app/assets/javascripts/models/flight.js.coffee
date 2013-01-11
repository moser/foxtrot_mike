class F.Models.Flight extends F.BaseModel
  paramRoot: 'flight'
  urlRoot: '/flights'
  defaults:
    departure_date: Format.date_to_s(new Date())
    purpose: "training"
    departure_i: -1
    arrival_i: -1
    comment: ""
    is_tow: false
    editable: true

  departure_date: ->
    Parse.date_to_s(@get("departure_date"))

  #departure time in ms
  sortBy: ->
    Date.parse(@get("departure_date")) + (@get("departure_i") || 0) * 60000

  plane: ->
    if @get("plane_id")?
      F.planes.get(@get("plane_id"))

  seat1_person: ->
    if @get("seat1_person_id")?
      F.people.get(@get("seat1_person_id"))

  seat2_person: ->
    if @get("seat2_person_id")?
      F.people.get(@get("seat2_person_id"))

  controller: ->
    if @get("controller_id")?
      F.people.get(@get("controller_id"))

  from: ->
    if @get("from_id")?
      F.airfields.get(@get("from_id"))

  to: ->
    if @get("to_id")?
      F.airfields.get(@get("to_id"))

  cost_responsible: ->
    if @get("cost_responsible_id")?
      F.people.get(@get("cost_responsible_id"))

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
        @ilaunch = F.flights.get(@get("launch").id) || new F.Models.Flight(@get("launch"))
      else if @launch_type() == "wire_launch"
        @ilaunch = new F.Models.WireLaunch(@get("launch"))
    @ilaunch

  change_launch_type: (launch_type) ->
    @ilaunch = null
    if launch_type == "tow_launch"
      @ilaunch = new F.Models.Flight({ from_id: @get("from_id"), to_id: @get("from_id"), departure_i: @get("departure_i"), type: "TowFlight", is_tow: true})
    else if launch_type == "wire_launch"
      @ilaunch = new F.Models.WireLaunch({ type: "WireLaunch" })
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
        @trigger("sync")
        if @launch_type() == "tow_launch"
          unless F.flights.get(@launch().id)?
            F.flights.add(@launch())
          @launch().fetch()
          @launch().trigger("sync")
        else if @launch_type() == "wire_launch"
          @launch().trigger("sync")
        f = F.flights.find((f) => f.get("abstract_flight_id") == @id)
        f.fetch() if f?

  destroy: ->
    super success: =>
      @trigger("destroy")
      f = F.flights.find((f) => f.get("abstract_flight_id") == @id)
      f.fetch() if f?


  fetch: ->
    super
      success: =>
        @trigger("sync")
      error: (m, x, o) =>
        if x.status == 404
          F.flights.remove(m)

  save_launch: ->
    if @launch_type() == "tow_launch" || @launch_type() == "wire_launch"
      @set("launch_attributes", @launch().toJSON())
    else
      @unset("launch_attributes")

  liabilities: ->
    if !@liabilities_collection? && @id?
      @liabilities_collection = new F.Collections.Liabilities(@get("liabilities"))
      @liabilities_collection.url = "#{@url()}/liabilities"
      @liabilities_collection.flight = @
    @liabilities_collection

  cost_free_sum: ->
    if cost = @get("cost")
      free_sum = cost.free_sum
      if @launch()?
        free_sum = free_sum + @launch().cost_free_sum()
      free_sum
    else
      0

F.Collections.Flights = Backbone.Collection.extend
  model: F.Models.Flight
  url: '/flights'

  setFilter: (filter) ->
    @filter = filter
    @updateUrl()

  setRange: (range) ->
    @range = range
    @updateUrl()

  updateUrl: ->
    @url = "/flights"
    if @filter.resource? && @filter.id?
      @url = "/#{@filter.resource}/#{@filter.id}/flights"
    if @range?
      @url = "#{@url}/range/#{@range}"

  comparator: (a,b) ->
    a = a.sortBy()
    b = b.sortBy()
    if a == b then 0 else if a < b then 1 else -1
