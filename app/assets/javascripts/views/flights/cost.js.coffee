class F.Views.Flights.Cost extends F.TemplateView
  className: "edit"
  templateName: "flights/cost"

  initialize: ->
    @listenTo(@model, "sync", => @render())
    @render()

  render: ->
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))
