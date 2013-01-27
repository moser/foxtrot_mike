F.Presenters.Flight =
  present: (model) ->
    if model.seat2_person()?
      seat2 = PersonPresenter.present(model.seat2_person()).name
    else if model.get("seat2_n") > 0
      seat2 = "+#{model.get("seat2_n")}"
    else
      seat2 = ""
    if model.get("comment").length > 18
      comment = "#{model.get("comment").substring(0,15)}..."
    else
      comment = model.get("comment")
    r =
      id: model.id
      date: I18n.l("date.formats.default", model.get("departure_date"))
      plane: if model.plane()? then model.plane().get("registration") else ""
      seat1: if model.seat1_person()? then PersonPresenter.present(model.seat1_person()).name else ""
      seat2: seat2
      launch_type: model.launch_type()
      launch_type_short: I18n.t("flight.launch_types.#{ model.launch_type() }.short")
      launch_type_long: I18n.t("flight.launch_types.#{ model.launch_type() }.long")
      launch: model.launch()
      purpose_short: I18n.t("flight.purposes.#{ model.get("purpose") }.short")
      purpose_long: I18n.t("flight.purposes.#{ model.get("purpose") }.long")
      from: if model.from()? then AirfieldPresenter.present(model.from()) else {short: "", long: ""}
      to: if model.to()? then AirfieldPresenter.present(model.to()) else {short: "", long: ""}
      departure: Util.intTimeToString(model.get("departure_i"))
      arrival: Util.intTimeToString(model.get("arrival_i"))
      duration: Util.intTimeToString(model.duration())
      controller: if model.controller()? then PersonPresenter.present(model.controller()).name else ""
      cost_hint: if model.cost_hint()? then model.cost_hint().get("name") else ""
      comment_short: comment
      comment_long: model.get("comment")
      is_tow: model.get("is_tow")
      editable: model.get("editable")
      cost: model.get("cost")
      cost_free_sum: model.cost_free_sum()
      problems_exist: model.get("problems_exist")
      problem_count: if model.get("problems_exist") then _.keys(model.get("problems")).length else ""
      problems: model.get("problems")
      raw: model

WireLaunchPresenter = F.Presenters.WireLaunch =
  present: (model) ->
    r =
      wire_launcher: if model.wire_launcher()? then model.wire_launcher().get("registration") else ""
      operator: if model.operator()? then PersonPresenter.present(model.operator()).name else ""
      editable: model.get("editable")
      raw: model

PersonPresenter = F.Presenters.Person =
  present: (model) ->
    if model?
      name = "#{model.get("firstname")} #{model.get("lastname")}"
      firstname = model.get("firstname")
      lastname = model.get("lastname")
    else
      name = I18n.t("unknown_person")
      firstname = ""
      lastname = ""
    r =
      name: name
      firstname: firstname
      lastname: lastname

AirfieldPresenter = F.Presenters.Airfield =
  present: (model) ->
    if model.get("registration")? && model.get("registration") != ""
      short = model.get("registration")
      long = "#{model.get("name")} (#{model.get("registration")})"
    else
      short = model.get("name")
      long = short
    r =
      short: short
      long: long

Util = F.Util =
  intTimeToString: (i) ->
    if i < 0
      "--:--"
    else
      m = i % 60
      if m < 10
        "#{Math.floor(i / 60)}:0#{m}"
      else
        "#{Math.floor(i / 60)}:#{m}"
  stringTimeToInt: (s) ->
    t = Parse.time(s)
    if t
      t.h * 60 + t.m
    else
      -1
  currencyToString: (i) ->
    i = Math.round(i)
    e = Math.floor(i / 100.0)
    c = i % 100
    if c < 10
      "#{e},0#{c} €"
    else
      "#{e},#{c} €"

  percentageToString: (f) ->
    "#{Math.round(f * 100)} %"
    
