class F.Views.Flights.Edit extends F.TemplateView
  className: "edit"
  templateName: "flights/edit"
  events:
    'click .save': 'save'
    'click .reset': 'reset'
    'click .delete': 'delete'

  delegateEvents: ->
    super()
    _.each [@edit_flight, @edit_launch], ((v) -> v.delegateEvents())

  save: (e) ->
    _.each [@edit_flight, @edit_launch], ((v) -> v.update_model())
    if @model.invalidFields().length == 0
      @model.save()
      @renderSubViews()
    else
      @$(".error").effect("highlight", {}, 3000)
    false

  reset: (e) ->
    @model.reset()
    @renderSubViews()
    @subview_changed()
    false

  delete: (e) ->
    new F.Views.YesNo
      model:
        info:
          title: I18n.t("views.destroy")
          message: I18n.t("views.areusure")
        yes: =>
          @model.destroy()
    false

  initialize: ->
    @model = @options.model
    @render()
    @edit_flight = new F.Views.Flights.EditFlight({el: @$(".edit_flight"), model: @model})
    @edit_launch = new F.Views.Flights.EditLaunch({el: @$(".edit_launch"), model: @model})
    _.each [@edit_flight, @edit_launch], ((v) -> v.bind("changed", @subview_changed)), @

  render: ->
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))

  renderSubViews: ->
    _.each [@edit_flight, @edit_launch], ((v) -> v.render())

  subview_changed: =>
    if @model.dirty()
      @$("a.btn.save").addClass("btn-warning")
    else
      @$("a.btn.save").removeClass("btn-warning")
