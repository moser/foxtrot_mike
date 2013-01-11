class F.Views.Flights.Problems extends F.TemplateView
  className: "edit"
  templateName: "flights/problems"

  initialize: ->
    @listenTo(@model, "sync", => @render())
    @render()

  render: ->
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))
