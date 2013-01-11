class F.Views.Flights.EditLaunch extends F.TemplateView
  className: "edit_launch"
  templateName: "flights/edit_launch"

  events:
    'change .launch_type': 'change_launch_type'

  delegateEvents: ->
    super()
    @subview.delegateEvents if @subview?

  update_model: ->
    @subview.update_model() if @subview?

  change_launch_type: ->
    @model.change_launch_type(@$(".launch_type").val())
    @render()
    @trigger("changed")

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))
    @$('.launch_type').val(@model.launch_type())
    @subview = @create_sub_view()
    @subview.on("changed", => @trigger("changed")) if @subview?

  create_sub_view: ->
    switch @model.launch_type()
      when "self_launch"
        null
      when "tow_launch"
        new F.Views.Flights.EditFlight({el: @$(".launch_form"), model: @model.launch()})
      when "wire_launch"
        new F.Views.WireLaunches.Edit({el: @$(".launch_form"), model: @model.launch()})
