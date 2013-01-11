class F.Views.Flights.EditFlight extends F.ModelBasedView
  className: "edit_flight"
  templateName: "flights/edit_flight"

  events:
    'focus input.edit_field': 'edit_field'
    'change input.time': 'changeTimes'
    'change input': 'change'

  changeTimes: ->
    _.each ["departure_i", "arrival_i"], (f) =>
      @$("input[name=#{f}]").val(F.Util.stringTimeToInt(@$("input[name=#{f}_front]").val()))
      @$("input[name=#{f}_front]").val(F.Util.intTimeToString(@$("input[name=#{f}]").val()))
    @update_model()
    @$("input[name=duration_front]").val(F.Util.intTimeToString(@model.duration()))

  edit_field: (e) ->
    target = @$(e.target)
    field = target.attr("data-edit")
    unless target.siblings(".searchParent").length > 0
      switch field
        when "plane"
          params =
            list: F.planes.models
            label: (p) -> p.get("registration")
            score: (p) -> 1
            match: (p, q) -> p.get("registration").toLowerCase().indexOf(q.toLowerCase()) > -1
        when "seat1_person"
          params =
            list: F.people.models
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().lastname} #{p.present().firstname}"
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "seat2"
          params =
            list: _.flatten([new F.Models.NoPerson(), F.people.models, new F.Models.NPersons(1), new F.Models.NPersons(2), new F.Models.NPersons(3)])
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().lastname} #{p.present().firstname}"
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "controller"
          params =
            list: _.flatten([new F.Models.NoPerson(), F.people.models])
            label: (p) -> p.present().name
            score: (p) -> "#{1} #{p.present().lastname} #{p.present().firstname}"
            match: (p, q) -> p.present().name.toLowerCase().indexOf(q.toLowerCase()) > -1
        when "from", "to"
          present = (p) -> F.Presenters.Airfield.present(p)
          params =
            list: F.airfields.models
            label: (p) -> present(p).long
            score: (p) -> "#{p.get("name")}"
            match: (p, q) -> present(p).long.toLowerCase().indexOf(q.toLowerCase()) > -1
      
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
    @$el.html(@template({ flight: F.Presenters.Flight.present(@model) }))
    @$("input[name=departure_date_front]").datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "input[name=departure_date]", altFormat: "yy-mm-dd")
