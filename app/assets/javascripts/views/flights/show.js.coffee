class F.Views.Flights.Show extends F.TemplateView
  className: "flight"
  templateName: "flights/show"
  marked: false

  events:
    "click span": "detailsEvent"
    "click .summary": "detailsEvent"
    "click .mark": "clickMarker"

  renderMarker: ->
    mark = @$("button.mark")
    if @marked
      mark.addClass("active")
      mark.parents(".flight").addClass("marked")
    else
      mark.removeClass("active")
      mark.parents(".flight").removeClass("marked")

  setMarked: (b) ->
    @marked = b
    @renderMarker()

  clickMarker: (e) ->
    mode = "single"
    if e.shiftKey
      mode = "multi"
    if e.altKey
      mode = "aggregation"
    @trigger("marked_changed", {view: @, mode: mode, model: @model})
    e.stopPropagation()

  delegateEvents: ->
    super()
    @detailsView.delegateEvents() if @detailsView?

  expanded: false

  detailsEvent: ->
    @details(true)

  details: (check_dirty) ->
    unless @detailsView?
      @detailsView = new F.Views.Flights.Details({model: @model})
      @$el.append(@detailsView.$el.hide())
      @detailsView.$el.slideDown SlideDuration, =>
        @expanded = true
        @detailsView.$el.scrollintoview({offset: 40})
      @$el.addClass("expanded")
    else
      unless @model.dirty() && check_dirty
        @detailsView.$el.slideUp SlideDuration, =>
          @detailsView.$el.remove()
          @detailsView = null
          @expanded = false
        @$el.removeClass("expanded")
      else
        new F.Views.CancelResetSaveDialogView
          model:
            info:
              title: I18n.t("views.dialog.unsaved.title")
              message: I18n.t("views.dialog.unsaved.message")
            reset: =>
              @detailsView.edit_view.reset()
              @details(false)
            save: =>
              @detailsView.edit_view.save()
              @details(false)
    false

  initialize: ->
    _.extend(@, Backbone.Events)
    @no_summary = @options.no_summary || false
    @model = @options.model
    @model.on("change", @renderSummary)
    @model.on("sync", @renderSummary)
    @$el.attr("data-duration", Math.abs(@model.duration() + 1) - 1)

  renderSummary: () =>
    @$el.attr("data-aggregation-id", @model.get("aggregation_id"))
    @$el.find(".summary").remove()
    @$el.prepend(@template({ flight: F.Presenters.Flight.present(@model) })) unless @no_summary

  render: () =>
    @renderSummary()
    @$el.attr("id", @model.id)
    @renderMarker()
    if @detailsView?
      @detailsView.render()
