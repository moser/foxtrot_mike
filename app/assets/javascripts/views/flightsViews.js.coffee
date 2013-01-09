SlideDuration = 200

Flights.Routers.FlightsRouter = Backbone.Router.extend
  routes:
    "flights": "showIndex"
    ":filter_resource/:filter_id/flights": "showIndex"
    ":filter_resource/:filter_id/flights/range/:range": "showIndex"
    "flights/:id": "show"

  showIndex: (filter_resource, filter_id, range)->
    @index = new Flights.Views.Index(el: $('.app_container'), filter: { resource: filter_resource, id: filter_id }, range: range)

  show: (id) ->
    unless @index?
      @showIndex()
    @index.show(id)
      

class Flights.Views.Index extends Flights.TemplateView
  className: "flights_index"
  templateName: "flights/index"

  events:
    "click a.new_flight": "new"
    "click a.print": "print"
    "change #range_from_front" : "updateRange"
    "change #range_to_front" : "updateRange"

  render: ->
    @$el.html(@template({}))
    @collection.each (e) =>
      @$(".flights .flight_group").append (@views[e.id] = new Flights.Views.Show({ model: e })).el
      @views[e.id].render()
    @updateAggregation()

  change: (model) =>
    @updateAggregation()
    if model.id? && (_.has(model.changedAttributes(), "departure_i") || _.has(model.changedAttributes(), "departure_date"))
      @add(model)
  
  add: (model) =>
    if @views[model.id]?
      view = @views[model.id]
    else
      view = @views[model.id] = new Flights.Views.Show({ model: model })
      view.render()
    @$("##{model.id}").remove()
    @$(".flights .flight_group").prepend(view.el)
    _.sortBy(@collection.models, (e) -> e.sortBy()).reverse().map (f) =>
      @$(".flights .flight_group").append(@views[f.id].$el) if @views[f.id]?
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

  updateAggregation: ->
    @$("span.count").html("#{@collection.length}")
    @$("span.sum").html("#{Flights.Util.intTimeToString(@collection.map((f) -> if f.duration() > 0 then f.duration() else 0).reduce(((a, e) -> a + e), 0))}")

  updateRange: =>
    @range._from = Parse.date_to_s(@$("#range_from").val())
    @range._to = Parse.date_to_s(@$("#range_to").val())
    if @collection.range != @range.toString()
      @collection.setRange(@range.toString())
      @collection.fetch({ update: true })
  
  initialize: ->
    @new_view = null
    @views = {}
    @collection = Flights.flights
    @collection.setFilter(@options.filter)
    @collection.setRange(@options.range)
    @collection.on("change", @change)
    @collection.on("add", @add)
    @collection.on("remove", @remove)
    @render()
    if @options.range?
      @range = Flights.Models.Range.fromString(@options.range)
    else
      @range = new Flights.Models.Range(@collection.last().departure_date(), @collection.first().departure_date())
    @$("#range_from").val(Format.date_to_s(@range.from()))
    @$("#range_to").val(Format.date_to_s(@range.to()))
    @$("#range_from_front").val(Format.date_short(@range.from())).datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "#range_from", altFormat: "yy-mm-dd")
    @$("#range_to_front").val(Format.date_short(@range.to())).datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "#range_to", altFormat: "yy-mm-dd")

  #creates a new flight
  new: ->
    unless @new_view?
      @new_flight = new Flights.Models.Flight()
      chng = =>
        @new_flight.off("sync", chng)
        @new_view.$el.remove()
        @new_view = null
        @add(@new_flight)
        @show(@new_flight.id)
        @new_flight = null
      @new_flight.on("sync", chng)
      @new_view = new Flights.Views.Show({ model: @new_flight, no_summary: true })
      @new_view.details()
      @new_view.$(".summary").remove()
      Flights.flights.add(@new_flight, { silent: true })
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
    

class Flights.Views.Show extends Flights.TemplateView
  className: "flight"
  templateName: "flights/show"

  events:
    "click span": "detailsEvent"
    "click .summary": "detailsEvent"

  delegateEvents: ->
    super()
    @detailsView.delegateEvents() if @detailsView?

  expanded: false

  detailsEvent: ->
    @details(true)

  details: (check_dirty) ->
    unless @detailsView?
      @detailsView = new Flights.Views.Details({model: @model})
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
        new Flights.Views.CancelResetSaveDialogView
          model:
            info:
              title: "Unsaved..."
              message: "There is unsaved state, would you really like to BLA"
            reset: =>
              @detailsView.edit.reset()
              @details(false)
            save: =>
              @detailsView.edit.save()
              @details(false)
    false

  initialize: ->
    @no_summary = @options.no_summary || false
    @model = @options.model
    @model.on("change", @renderSummary)
    @model.on("sync", @renderSummary)
    @$el.attr("data-duration", Math.abs(@model.duration() + 1) - 1)

  renderSummary: () =>
    @$el.attr("data-aggregation-id", @model.get("aggregation_id"))
    @$el.find(".summary").remove()
    @$el.prepend(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) })) unless @no_summary

  render: () =>
    @renderSummary()
    @$el.attr("id", @model.id)
    if @detailsView?
      @detailsView.render()

class Flights.Views.Details extends Flights.TemplateView
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
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))
    @edit_view = new Flights.Views.Edit({el: @$(".edit"), model: @model, parentView: this})
    if !@model.get("is_tow") && @model.id?
      @liabilities_view = new Flights.Views.LiabilitiesIndex({ el: @$(".liabilities"), collection: @model.liabilities(), flight: @model })


class Flights.Views.Edit extends Flights.TemplateView
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
    @model.save()
    @renderSubViews()
    false

  reset: (e) ->
    @model.reset()
    @renderSubViews()
    @subview_changed()
    false

  delete: (e) ->
    @model.destroy()
    false

  initialize: ->
    @model = @options.model
    @render()
    @edit_flight = new Flights.Views.EditFlight({el: @$(".edit_flight"), model: @model})
    @edit_launch = new Flights.Views.EditLaunch({el: @$(".edit_launch"), model: @model})
    _.each [@edit_flight, @edit_launch], ((v) -> v.bind("changed", @subview_changed)), @

  render: ->
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))

  renderSubViews: ->
    _.each [@edit_flight, @edit_launch], ((v) -> v.render())

  subview_changed: =>
    if @model.dirty()
      @$("a.btn.save").addClass("btn-warning")
    else
      @$("a.btn.save").removeClass("btn-warning")

class Flights.Views.EditFlight extends Flights.ModelBasedView
  className: "edit_flight"
  templateName: "flights/edit_flight"

  events:
    'focus input.edit_field': 'edit_field'
    'change input.time': 'changeTimes'
    'change input': 'change'

  changeTimes: ->
    _.each ["departure_i", "arrival_i"], (f) =>
      @$("input[name=#{f}]").val(Flights.Util.stringTimeToInt(@$("input[name=#{f}_front]").val()))
      @$("input[name=#{f}_front]").val(Flights.Util.intTimeToString(@$("input[name=#{f}]").val()))
    @update_model()
    @$("input[name=duration_front]").val(Flights.Util.intTimeToString(@model.duration()))

  edit_field: (e) ->
    target = @$(e.target)
    field = target.attr("data-edit")
    unless target.siblings(".searchParent").length > 0
      switch field
        when "plane"
          params =
            list: Flights.planes.models
            label: (p) -> p.get("registration")
            score: (p) -> 1
            match: (p, q) -> p.get("registration").toLowerCase().indexOf(q.toLowerCase()) > -1
        when "seat1_person"
          params =
            list: Flights.people.models
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().lastname} #{p.present().firstname}"
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "seat2"
          params =
            list: _.flatten([new Flights.Models.NoPerson(), Flights.people.models, new Flights.Models.NPersons(1), new Flights.Models.NPersons(2), new Flights.Models.NPersons(3)])
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().lastname} #{p.present().firstname}"
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "controller"
          params =
            list: _.flatten([new Flights.Models.NoPerson(), Flights.people.models])
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().lastname} #{p.present().firstname}"
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "from", "to"
          present = (p) -> Flights.Presenters.Airfield.present(p)
          params =
            list: Flights.airfields.models
            label: (p) -> present(p).long
            score: (p) -> "#{p.get("name")}"
            match: (p, q) -> present(p).long.toLowerCase().indexOf(q.toLowerCase()) > -1
      
      params["for"] = @$(e.target).siblings("input[name=#{field}_id]")
      params["span"] = @$(e.target)
      params["callback"] = => @change()
      target.data("searchParent", c = new Flights.Views.SearchParent(params))
      target.before(c.$el)
    else
      target.data("searchParent").release()
    false

  update_model: ->
    attr = {}
    _.each [ "departure_date", "plane_id", "seat1_person_id", "from_id",
             "to_id", "departure_i", "arrival_i", "controller_id" ], ((f) ->
               if @$("input[name=#{f}]").length > 0
                 attr[f] = @$("input[name=#{f}]").val()), @
    _.each [ "departure_i", "arrival_i" ], ((f) ->
               if @$("input[name=#{f}]").length > 0
                 attr[f] = parseInt(@$("input[name=#{f}]").val())), @
    attr["comment"] = @$("textarea[name=comment]").val()
    seat2_val = @$("input[name=seat2_id]").val()
    if seat2_val.indexOf("+") == 0
      attr["seat2_n"] = parseInt(seat2_val)
      attr["seat2_person_id"] = undefined
    else if seat2_val.length > 0
      attr["seat2_n"] = 0
      attr["seat2_person_id"] = seat2_val
    else
      attr["seat2_n"] = 0
      attr["seat2_person_id"] = undefined
    @model.set(attr)

  initialize: ->
    super()
    @render()
    @model.on("change", => @render())

  render: ->
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))
    @$("input[name=departure_date_front]").datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "input[name=departure_date]", altFormat: "yy-mm-dd")


class Flights.Views.EditLaunch extends Flights.TemplateView
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
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))
    @$('.launch_type').val(@model.launch_type())
    @subview = @create_sub_view()
    @subview.on("changed", => @trigger("changed")) if @subview?

  create_sub_view: ->
    switch @model.launch_type()
      when "self_launch"
        null
      when "tow_launch"
        new Flights.Views.EditFlight({el: @$(".launch_form"), model: @model.launch()})
      when "wire_launch"
        new Flights.Views.EditWireLaunch({el: @$(".launch_form"), model: @model.launch()})

class Flights.Views.EditWireLaunch extends Flights.ModelBasedView
  className: "edit_wire_launch"
  templateName: "flights/edit_wire_launch"
  
  events:
    'change input': 'change'
    'focus input.edit_field': 'edit_field'

  edit_field: (e) ->
    target = @$(e.target)
    field = target.attr("data-edit")
    unless target.siblings(".searchParent").length > 0
      switch field
        when "wire_launcher"
          params =
            list: Flights.wire_launchers.models
            label: (p) -> p.get("registration")
            score: (p) -> 1
            match: (p, q) -> p.get("registration").toLowerCase().indexOf(q.toLowerCase()) > -1
        when "operator"
          present = (p) -> Flights.Presenters.Person.present(p)
          params =
            list: Flights.people.models
            label: (p) -> present(p).name
            score: (p) -> "#{1} #{present(p).lastname} #{present(p).firstname}"
            match: (p, q) -> present(p).name.toLowerCase().indexOf(q.toLowerCase()) > -1
      params["for"] = @$(e.target).siblings("input[name=#{field}_id]")
      params["span"] = @$(e.target)
      params["callback"] = => @change()
      target.data("searchParent", c = new Flights.Views.SearchParent(params))
      target.before(c.$el)
    else
      target.data("searchParent").release()
    false

  update_model: ->
    attr = {}
    _.each [ "wire_launcher_id", "operator_id" ], ((f) ->
               if @$("input[name=#{f}]").length > 0
                 attr[f] = @$("input[name=#{f}]").val()), @
    @model.set(attr)

  initialize: ->
    super()
    @render()

  render: ->
    @$el.html(@template({ wire_launch: Flights.Presenters.WireLaunch.present(@model) }))

class Flights.Views.LiabilitiesIndex extends Flights.TemplateView
  className: 'liabilities'
  templateName: 'liabilities/index'

  events:
    "click a.new": "new"

  checkDefault: =>
    if @collection.length == 0
      @$("tr.default").show()
    else
      @$("tr.default").hide()

  new: =>
    @collection.add(new Flights.Models.Liability(flight_id: @flight.id))

  add: (model) =>
    @$("tbody").append (@views[model.cid] = new Flights.Views.LiabilityShow({ model: model, collection: @collection })).el
    @views[model.cid].render()
    @views[model.cid].edit()
    @checkDefault()

  remove: (model) =>
    view = @views[model.cid]
    view.remove()
    view.$el.remove()
    @views[model.cid] = null
    @checkDefault()
  
  initialize: ->
    super()
    @flight = @options.flight
    @collection = @options.collection
    @collection.on("change", @change)
    @collection.on("add", @add)
    @collection.on("remove", @remove)
    @views = {}
    @render()
    @checkDefault()

  render: ->
    @$el.html(@template({ flight: @flight }))
    @collection.each (e) =>
      @$("tbody").append (@views[e.cid] = new Flights.Views.LiabilityShow({ model: e, collection: @collection })).el
      @views[e.cid].render()

class Flights.Views.LiabilityShow extends Flights.TemplateView
  className: "liability"
  tagName: "tr"
  templateName: "liabilities/show"

  events:
    'click a.edit': 'edit'
    'click a.destroy': 'destroy'

  edit: ->
    unless @editView?
      @editView = new Flights.Views.EditLiability(model: @model, collection: @collection, parent: @)
      @$el.hide().after(@editView.el)

  destroy: =>
    @stopListening()
    @model.destroy()

  show: =>
    @editView = null
    @$el.show()

  remove: (model) =>
    unless model == @model
      @updateView()
    else
      @stopListening()

  initialize: ->
    super()
    @listenTo(@options.collection, "add", @updateView)
    @listenTo(@options.collection, "change", @updateView)
    @listenTo(@options.collection, "remove", @remove)
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ liability: @model }))
    @updateView()

  updateView: ->
    @$("td.person").html(Flights.Presenters.Person.present(@model.person()).name)
    @$("td.proportion").html(@model.get("proportion"))
    @$("td.percentage").html(Flights.Util.percentageToString(@model.collection.percentage_for(@model)))
    @$("td.value").html(Flights.Util.currencyToString(@model.collection.percentage_for(@model) * @model.flight().cost_free_sum()))
    
class Flights.Views.EditLiability extends Flights.ModelBasedView
  className: "edit_liability"
  tagName: "tr"
  templateName: "liabilities/form"

  events:
    'focus input.edit_field': 'edit_field'
    'change input': 'change'
    'click a.save': 'save'
    'click a.cancel': 'reset'

  edit_field: (e) ->
    target = @$(e.target)
    unless target.siblings(".searchParent").length > 0
      present = (p) -> Flights.Presenters.Person.present(p)
      params =
        list: Flights.people.models
        label: (p) -> present(p).name
        score: (p) -> "#{1} #{present(p).lastname} #{present(p).firstname}"
        match: (p, q) -> present(p).name.toLowerCase().indexOf(q.toLowerCase()) > -1
        for: @$(e.target).siblings("input[name=person_id]")
        span: @$(e.target)
      target.data("searchParent", c = new Flights.Views.SearchParent(params))
      target.before(c.$el)
    else
      target.data("searchParent").release()
    false

  update_model: ->
    @model.set(proportion: parseInt(@$("input[name=proportion]").val()), person_id: @$("input[name=person_id]").val())

  save: =>
    @update_model()
    if @model.valid()
      @model.save()
      @hide()
    else
      @markInvalid()

  reset: =>
    if @model.id?
      @model.reset()
    else
      @model.destroy()
    @hide()

  hide: =>
    @stopListening()
    @$el.remove()
    @parent.show()

  destroy: =>
    @stopListening()

  initialize: ->
    super()
    @parent = @options.parent
    @listenTo(@model, "change", @updateView)
    @listenTo(@options.collection, "change", @updateView)
    @listenTo(@options.collection, "remove", @updateView)
    @listenTo(@model, "remove", @destroy)
    @render()

  render: ->
    @$el.html(@template({ liability: @model }))
    @updateView()

  updateView: =>
    @$("input[name=person_id]").val(@model.get("person_id"))
    @$("input[name=person_front]").val(if @model.person()? then Flights.Presenters.Person.present(@model.person()).name else "")
    @$("input[name=proportion]").val(@model.get("proportion"))
    @$("td.percentage").html(Flights.Util.percentageToString(@model.collection.percentage_for(@model)))
    @$("td.value").html(Flights.Util.currencyToString(@model.collection.percentage_for(@model) * @model.flight().cost_free_sum()))

  markInvalid: =>
    @$(".control-group").removeClass("error")
    @$(".person").addClass("error") unless @model.personValid()
    @$(".proportion").addClass("error") unless @model.proportionValid()
    
