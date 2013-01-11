class F.Views.Flights.Details extends F.TemplateView
  className: "details"
  templateName: "flights/details"

  delegateEvents: ->
    super()
    @edit_view.delegateEvents() if @edit_view?
    @liabilities_view.delegateEvents() if @liabilities_view?

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))
    @cost_view = new F.Views.Flights.Cost({ el: @$(".cost"), model: @model })
    @edit_view = new F.Views.Flights.Edit({el: @$(".edit"), model: @model, parentView: this})
    if !@model.get("is_tow") && @model.id?
      @liabilities_view = new F.Views.Liabilities.Index({ el: @$(".liabilities"), collection: @model.liabilities(), flight: @model })
