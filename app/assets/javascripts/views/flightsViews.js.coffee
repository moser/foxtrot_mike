Flights.Routers.FlightsRouter = Backbone.Router.extend
  routes:
    "": "index"

  index: ->
    @index = new Flights.Views.Index(el: $('.app_container'))


Flights.Views.Index = Backbone.View.extend
  tagName: "div"
  className: "flights_index"

  template: (o) ->
    JST["flights/index"](o)

  render: ->
    @$el.html(@template({}))
    @collection.each (e) ->
      x = new Flights.Views.Show({ model: e})
      @$(".flights .flight_group").append(x.el)
      x.render()

  initialize: ->
    @collection = Flights.flights
    @render()

Flights.Views.Show = Backbone.View.extend
  tagName: "div"
  className: "flight"

  events:
    "click span": "details"

  details: ->
    d = new Flights.Views.Details({model: @model})
    @$el.append(d.el)

  template: (o) ->
    JST["flights/show"](o)

  initialize: ->
    @model = @options.model
    self = this
    @model.on "change", () ->
      self.render()
    @$el.attr("data-duration", Math.abs(@model.duration() + 1) - 1)

  render: () ->
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))

Flights.Views.Details = Backbone.View.extend
  tagName: "div"
  className: "details"

  template: (o) ->
    JST["flights/details"](o)

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))

