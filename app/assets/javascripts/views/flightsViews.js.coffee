SlideDuration = 200

Flights.Routers.FlightsRouter = Backbone.Router.extend
  routes:
    "": "index"

  index: ->
    @index = new Flights.Views.Index(el: $('.app_container'))

class Flights.Views.Index extends Flights.TemplateView
  className: "flights_index"
  templateName: "flights/index"

  events:
    "click a.new_flight": "new"

  render: ->
    @$el.html(@template({}))
    @collection.each (e) ->
      x = new Flights.Views.Show({ model: e })
      @$(".flights .flight_group").append(x.el)
      x.render()

  change: ->
    #TODO sort
  
  add: (model) =>
    #TODO sort
    x = new Flights.Views.Show({ model: model })
    @$(".flights .flight_group").append(x.el)
    x.render()


  remove: (model) =>
    #remove shows from DOM
    @$("##{model.id}").remove()
  
  initialize: ->
    @collection = Flights.flights
    @collection.on("change", @change)
    @collection.on("add", @add)
    @collection.on("remove", @remove)
    @render()

  #creates a new flight
  new: ->
    @new_flight = new Flights.Models.Flight()
    Flights.flights.add(@new_flight)
    @view = new Flights.Views.Show({ model: @new_flight })
    @view.details()
    @$(".flights .flight_group").prepend(@view.el)
    #@view.$el.scrollintoview({offset: 60})
    false
    

class Flights.Views.Show extends Flights.TemplateView
  className: "flight"
  templateName: "flights/show"

  events:
    "click span": "details"
    "click .summary": "details"

  expanded: false

  details: (check_dirty) ->
    unless @detailsView?
      @detailsView = new Flights.Views.Details({model: @model})
      @$el.append(@detailsView.$el.hide())
      @detailsView.$el.slideDown SlideDuration, =>
        @expanded = true
        @detailsView.$el.scrollintoview({offset: 40})
      @$el.addClass("expanded")
    else
      if @detailsView.dirty() && check_dirty
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
    @model = @options.model
    @model.on("change", @renderSummary)
    @model.on("sync", @render)
    @$el.attr("data-duration", Math.abs(@model.duration() + 1) - 1)

  renderSummary: () =>
    @$el.attr("data-aggregation-id", @model.get("aggregation_id"))
    @$el.find(".summary").remove()
    @$el.prepend(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))

  render: () =>
    @renderSummary()
    @$el.attr("id", @model.id)
    if @detailsView?
      @detailsView.render()

class Flights.Views.Details extends Flights.TemplateView
  className: "details"
  templateName: "flights/details"

  dirty: ->
    @edit.dirty()

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))
    @edit = new Flights.Views.Edit({el: @$(".edit"), model: @model, parentView: this})


class Flights.Views.Edit extends Flights.TemplateView
  className: "edit"
  templateName: "flights/edit"
  events:
    'click .save': 'save'
    'click .reset': 'reset'
    'click form li a': 'change_tab'

  change_tab: (e) ->
    @active_tab_link = $(e.target)

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

  dirty: ->
    #@model.dirty()
    @edit_flight.dirty() || @edit_launch.dirty()

  initialize: ->
    @model = @options.model
    @render()
    @active_tab_link = @$("form li a").first()
    @edit_flight = new Flights.Views.EditFlight({el: @$(".edit_flight"), model: @model})
    @edit_launch = new Flights.Views.EditLaunch({el: @$(".edit_launch"), model: @model})
    _.each [@edit_flight, @edit_launch], ((v) -> v.bind("changed", @subview_changed)), @

  render: ->
    @$el.html(@template())

  renderSubViews: ->
    _.each [@edit_flight, @edit_launch], ((v) -> v.render())
    @active_tab_link.tab("show")

  subview_changed: =>
    if @dirty()
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
          present = (p) -> Flights.Presenters.Person.present(p)
          params =
            list: Flights.people.models
            label: (p) -> present(p).name
            score: (p) -> "#{1} #{present(p).lastname} #{present(p).firstname}"
            match: (p, q) -> present(p).name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "controller"
          present = (p) -> Flights.Presenters.Person.present(p)
          params =
            list: Flights.people.models
            label: (p) -> present(p).name
            score: (p) -> "#{1} #{present(p).lastname} #{present(p).firstname}"
            match: (p, q) -> present(p).name.toLowerCase().indexOf(q.toLowerCase()) > -1
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
    _.each [ "departure_date", "plane_id", "seat1_person_id", "seat2_person_id", "from_id",
             "to_id", "departure_i", "arrival_i", "controller_id", "comment" ], ((f) ->
               if @$("input[name=#{f}]").length > 0
                 @model.set(f, @$("input[name=#{f}]").val())), @

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ flight: Flights.Presenters.FlightPresenter.present(@model) }))
    @$("input[name=departure_date_front]").datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "input[name=departure_date]", altFormat: "yy-mm-dd")


class Flights.Views.EditLaunch extends Flights.TemplateView
  className: "edit_launch"
  templateName: "flights/edit_launch"

  events:
    'change .launch_type': 'change_launch_type'

  dirty: ->
    @subview? && @subview.dirty()

  update_model: ->
    @subview? && @subview.update_model()

  change_launch_type: ->
    @model.change_launch_type(@$(".launch_type").val())
    @render()

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
    _.each [ "wire_launcher_id", "operator_id" ], ((f) ->
               if @$("input[name=#{f}]").length > 0
                 @model.set(f, @$("input[name=#{f}]").val())), @

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ wire_launch: Flights.Presenters.WireLaunch.present(@model) }))
