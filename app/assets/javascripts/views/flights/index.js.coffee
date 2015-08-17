class F.Views.Flights.Index extends F.TemplateView
  className: "flights_index"
  templateName: "flights/index"

  events:
    "click a.new_flight": "new"
    "click a.print": "print"
    "click a.csv": "csv"
    "click a.reorder": "reorder"
    "click a.load" : "updateRange"
    "click a.filter": "updateFilter"
    "submit form.filter": "updateFilter"
    "click .mark": "toggleMarkAll"
    "click .delete_selected": "deleteSelected"

  sort: (models) =>
    models = _.sortBy(models, (e) -> e.sortBy())
    if @order
      models.reverse()
    models

  reorder: =>
    @order = !@order
    @sort(@collection.models).forEach (model) =>
      @add(model, false)
    false

  render: ->
    @$el.html(@template({}))
    @sort(@collection.models).forEach (model) =>
      @add(model, false)
    @updateAggregation()

  change: (model) =>
    @updateAggregation()
    if model.id? && (_.has(model.changedAttributes(), "departure_i") || _.has(model.changedAttributes(), "departure_date"))
      @add(model)
  
  add: (model, needsOrdering=true) =>
    if @views[model.id]?
      view = @views[model.id]
    else
      view = @views[model.id] = new F.Views.Flights.Show({ model: model })
      view.on("marked_changed", @markedChanged)
      view.render()
    @$("##{model.id}").remove()
    if needsOrdering #make sure they get ordered properly
      sortedModels = @sort(@collection.models)
      idx = sortedModels.indexOf(model)
      if idx = 0
        @$(".flights .flight_group").prepend(@views[f.id].$el)
      else if idx >= sortedModels.length - 1
        @$(".flights .flight_group").append(@views[f.id].$el)
      else
        el = sortedModels[idx + 1].$el
        if el
          el.after(@views[f.id].$el)
    else
      @$(".flights .flight_group").append(view.el)
    #make sure the events are delegated correctly
    view.delegateEvents()
    @updateAggregation()

  show: (id) ->
    if @views[id]? && !@views[id].detailsView?
      @views[id].details()

  remove: (model) =>
    @$("##{model.id}").fadeOut =>
      @$("##{model.id}").remove()
      @views[model.id] = null
    @updateAggregation()

  toggleMarkAll: (e) ->
    if @markedViews.length == 0
      _.each @views, (v) =>
        v.setMarked(!v.marked)
        @markedViews.push(v)
    else
      _.each @views, (v) =>
        v.setMarked(false)
        @markedViews = []
    @updateAggregation()
    e.stopPropagation()

  markAggregation: (model) =>
    aggregationId = model.get("aggregation_id")
    _.each @views, (v) =>
      v.setMarked(false)
      @markedViews = []
    models = @collection.models
    walk = (direction) =>
      idx = models.indexOf(model)
      while idx >= 0 and idx < models.length and models[idx].get("aggregation_id") == aggregationId
        view = @views[models[idx].id]
        view.setMarked(true)
        @markedViews.push(view)
        idx += direction
        if not aggregationId
          break
    walk(1)
    walk(-1)
    @markedViews = _.unique(@markedViews)
    @updateAggregation()
    @markedViews[0].$el.scrollintoview()

  markedChanged: (evt) =>
    if evt.mode == "aggregation"
      @markAggregation evt.model
      return
    else if evt.mode == "single" || !@lastMarked? || @lastMarked == evt.view
      if evt.view.marked
        evt.view.setMarked(false)
        @markedViews = _.without(@markedViews, evt.view)
      else
        evt.view.setMarked(true)
        @markedViews.push(evt.view)
        @lastMarked = evt.view
    else
      el = @lastMarked.el
      other = evt.view.el
      while el? && el != other
        el = el.nextSibling
      if el?
        [ upper, lower ] = [ @lastMarked.el, evt.view.el ]
      else
        [ lower, upper ] = [ @lastMarked.el, evt.view.el ]

      cont = true
      while cont && upper?
        cont = upper != lower
        view = @views[upper.id]
        view.setMarked(true)
        @markedViews.push(view)
        upper = upper.nextSibling
    @markedViews = _.unique(@markedViews)
    @updateAggregation()

  deleteSelected: (e) ->
    if @markedViews.length > 0
      new F.Views.YesNo
        model:
          info:
            title: I18n.t("views.destroy")
            message: I18n.t("views.areusure")
          yes: =>
            _.each(@markedViews, (v) -> v.model.destroy())
    false

  showLoadingIndicator: =>
    $('.loading').css('display', 'block')

  hideLoadingIndicator: =>
    $('.loading').css('display', 'none')

  updateAggregation: ->
    sum = (col) -> F.Util.intTimeToString(col.map((f) -> if f.duration() > 0 then f.duration() else 0).reduce(((a, e) -> a + e), 0))
    if @markedViews.length > 0
      @$("div.markOverlay").show()
    else
      @$("div.markOverlay").hide()
    @$("span.count").text(@collection.length)
    @$("span.markedCount").text(@markedViews.length)
    @$("span.sum").text(sum(@collection))
    @$("span.markedSum").text(sum(_.map(@markedViews, (v) -> v.model)))
    @$("span.selected_count").html("(#{@markedViews.length})")

  updateRange: =>
    @range._from = Parse.date_to_s(@$("#range_from").val())
    @range._to = Parse.date_to_s(@$("#range_to").val())
    if @collection.range != @range.toString()
      @collection.setRange(@range.toString())
      @showLoadingIndicator()
      @collection.fetch
        update: true
        success: =>
          @hideLoadingIndicator()
    false

  updateFilter: =>
    search = @$("#filter_text").val()
    if @collection.search != search
      @collection.setSearch(search)
      @showLoadingIndicator()
      @collection.fetch
        update: true
        success: =>
          @hideLoadingIndicator()
    false
  
  initialize: ->
    @order = true
    @new_view = null
    @views = {}
    @markedViews = []
    @collection = F.flights
    @collection.setFilter(@options.filter)
    @collection.setRange(@options.range)
    @collection.on("change", @change)
    @collection.on("add", @add)
    @collection.on("remove", @remove)
    @render()
    @search = ''
    if @options.range?
      @range = F.Models.Range.fromString(@options.range)
    else
      @range = new F.Models.Range(@collection.last().departure_date(), @collection.first().departure_date())
    @$("#range_from").val(Format.date_to_s(@range.from()))
    @$("#range_to").val(Format.date_to_s(@range.to()))
    @$("#range_from_front").val(Format.date_short(@range.from())).datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "#range_from", altFormat: "yy-mm-dd")
    @$("#range_to_front").val(Format.date_short(@range.to())).datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "#range_to", altFormat: "yy-mm-dd")

    $(document).keydown @moveAggregationMark

  moveAggregationMark: (e) =>
      if e.altKey and (e.keyCode == 38 or e.keyCode == 40)
        sortedModelsMarked = @sort(@markedViews.map((view) -> view.model))
        sortedModels = @sort(@collection.models)
        if e.keyCode == 38 # up
          first = sortedModelsMarked[0]
          nextIdx = sortedModels.indexOf(first) - 1
          if nextIdx < 0
            nextIdx = 0
          console.log "up", first, sortedModels.indexOf(first), nextIdx
        else if e.keyCode == 40 # down
          last = sortedModelsMarked[sortedModelsMarked.length - 1]
          nextIdx = sortedModels.indexOf(last) + 1
          if nextIdx >= sortedModels.length
            nextIdx = sortedModels.length - 1
        @markAggregation(sortedModels[nextIdx])

  #creates a new flight
  new: ->
    unless @new_view?
      @new_flight = new F.Models.Flight()
      chng = =>
        @new_flight.off("sync", chng)
        @new_view.$el.remove()
        @new_view = null
        @add(@new_flight)
        @show(@new_flight.id)
        @new_flight = null
      @new_flight.on("sync", chng)
      @new_view = new F.Views.Flights.Show({ model: @new_flight, no_summary: true })
      @new_view.details()
      @new_view.$(".summary").remove()
      F.flights.add(@new_flight, { silent: true })
      @$(".flights .flight_group").prepend(@new_view.el)
    else
      @new_view.$el.slideUp SlideDuration, =>
        @new_view.$el.remove()
        @new_view = null
    false

  # create a pdf document the user can print
  print: ->
    ids = JSON.stringify(@collection.models.map((f) -> f.id))
    $("<form action=\"/pdfs\" method=\"POST\">
      <input type=\"hidden\" name=\"flight_ids\" value='#{ids}'></form>").appendTo($("body")).submit().remove()
    false

  # create a csv file
  csv: ->
    ids = JSON.stringify(@collection.models.map((f) -> f.id))
    $("<form action=\"/csvs\" method=\"POST\">
      <input type=\"hidden\" name=\"flight_ids\" value='#{ids}'></form>").appendTo($("body")).submit().remove()
    false
