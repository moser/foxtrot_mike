class F.Views.Flights.EditFlight extends F.ModelBasedView
  className: "edit_flight"
  templateName: "flights/edit_flight"

  events:
    'focus input.edit_field': 'edit_field'
    'focus input.time': 'select_all'
    'change input.time': 'changeTimes'
    'change input': 'change'

  select_all: (e) ->
    @$(e.target).select()

  changeTimes: ->
    _.each ["departure_i", "arrival_i"], (f) =>
      @$("input[name=#{f}]").val(F.Util.stringTimeToInt(@$("input[name=#{f}_front]").val()))
      @$("input[name=#{f}_front]").val(F.Util.intTimeToString(@$("input[name=#{f}]").val()))
    @update_model()
    @$("input[name=duration_front]").val(F.Util.intTimeToString(@model.duration()))

  edit_field: (e) ->
    target = @$(e.target)
    field = target.attr("data-edit")
    is_tow = F.Presenters.Flight.present(@model).is_tow
    unless target.siblings(".searchParent").length > 0
      switch field
        when "plane"
          params =
            list: F.planes.models
            label: (p) -> p.get("registration")
            score: (p) -> "#{p.get("disabled")} #{p.get("registration")}".toLowerCase()
            match: (p, q) -> p.get("registration").toLowerCase().indexOf(q.toLowerCase()) > -1
            next: @$(".seat1_person .edit_field")
        when "seat1_person"
          params =
            list: F.people.models
            label: (p) -> p.present().name
            score: (p) -> "#{p.present().disabled} #{p.present().lastname} #{p.present().firstname}".toLowerCase()
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
            next: @$(".seat2 .edit_field")
        when "seat2"
          params =
            list: _.flatten([new F.Models.NoPerson(), F.people.models, new F.Models.NPersons(1), new F.Models.NPersons(2), new F.Models.NPersons(3)])
            label: (p) -> p.present().name
            score: (p) -> "#{p.present().disabled} #{p.present().lastname} #{p.present().firstname}".toLowerCase()
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
            next: if is_tow then @$(".to .edit_field") else @$(".from .edit_field")
        when "controller"
          params =
            list: _.flatten([new F.Models.NoPerson(), F.people.models])
            label: (p) -> p.present().name
            score: (p) -> "#{p.present().disabled} #{p.present().lastname} #{p.present().firstname}".toLowerCase()
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
            next: @$(".cost_hint .edit_field")
        when "cost_hint"
          params =
            list: _.flatten([new F.Models.NoCostHint(), F.cost_hints.models])
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().name}".toLowerCase()
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
            next: @$(".comment textarea")
        when "from", "to"
          if field == "from"
            next_field = @$(".to .edit_field")
          else if is_tow
            next_field = @$(".times input[name=arrival_i_front]")
          else
            next_field = @$(".times input[name=departure_i_front]")
          present = (p) -> F.Presenters.Airfield.present(p)
          params =
            list: F.airfields.models
            label: (p) -> present(p).long
            score: (p) -> "#{p.get("disabled")} #{p.get("name")}".toLowerCase()
            match: (p, q) -> present(p).long.toLowerCase().indexOf(q.toLowerCase()) > -1
            next: next_field
      
      params["for"] = @$(e.target).siblings("input[name=#{field}_id]")
      params["span"] = @$(e.target)
      params["callback"] = => @change()
      target.data("searchParent", c = new F.Views.SearchParent(params))
      target.before(c.$el)
    else
      target.data("searchParent").release()
    false

  update_model: ->
    attr = {}
    _.each [ "departure_date", "plane_id", "seat1_person_id", "from_id",
             "to_id", "departure_i", "arrival_i", "controller_id", "cost_hint_id" ], ((f) ->
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
    @model.on("change", => @updateView())

  render: ->
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))
    @updateView()

  updateView: ->
    @$("input[name=departure_date_front]").datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "input[name=departure_date]", altFormat: "yy-mm-dd")
    p = F.Presenters.Flight.present(@model)
    @$("input[name=departure_date]").val(@model.get("departure_date"))
    @$("input[name=departure_date_front]").val(p.date)
    @$("input[name=plane_id]").val(@model.get("plane_id"))
    @$("input[name=plane_front]").val(p.plane)
    @$("input[name=seat1_person_id]").val(@model.get("seat1_person_id"))
    @$("input[name=seat1_person_front]").val(p.seat1)
    @$("input[name=seat2_id]").val(@model.get("seat2_person_id") || if @model.get("seat2_n") > 0 then "+#{@model.get("seat2_n")}" else "")
    @$("input[name=seat2_front]").val(p.seat2)
    @$("input[name=from_id]").val(@model.get("from_id"))
    @$("input[name=from_front]").val(p.from.long)
    @$("input[name=to_id]").val(@model.get("to_id"))
    @$("input[name=to_front]").val(p.to.long)
    @$("input[name=departure_i]").val(@model.get("departure_i"))
    @$("input[name=arrival_i]").val(@model.get("arrival_i"))
    @$("input[name=departure_i_front]").val(p.departure)
    @$("input[name=arrival_i_front]").val(p.arrival)
    @$("input[name=duration_front]").val(p.duration)
    @$("input[name=controller_id]").val(@model.get("controller_id"))
    @$("input[name=controller_front]").val(p.controller)
    @$("input[name=cost_hint_id]").val(@model.get("cost_hint_id"))
    @$("input[name=cost_hint_front]").val(p.cost_hint)
    @$("textarea[name=comment]").val(p.comment_long)
    @$(".control-group").removeClass("error")
    _.each(@model.invalidFields(),((f) -> @$(".control-group.#{f}").addClass("error")), @)
