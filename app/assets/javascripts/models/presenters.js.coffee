Flights.Presenters.FlightPresenter =
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
      plane: model.plane().get("registration")
      seat1: PersonPresenter.present(model.seat1_person()).name
      seat2: seat2
      launch_kind_short: I18n.t("flight.launch_types.#{ model.get("launch_kind") }.short")
      launch_kind_long: I18n.t("flight.launch_types.#{ model.get("launch_kind") }.long")
      purpose_short: I18n.t("flight.purposes.#{ model.get("purpose") }.short")
      purpose_long: I18n.t("flight.purposes.#{ model.get("purpose") }.long")
      from: AirfieldPresenter.present(model.from())
      to: AirfieldPresenter.present(model.to())
      departure: Util.intTimeToString(model.get("departure_i"))
      arrival: Util.intTimeToString(model.get("arrival_i"))
      duration: Util.intTimeToString(model.duration())
      controller: PersonPresenter.present(model.controller()).name
      comment_short: comment
      comment_long: model.get("comment")
      raw: model

PersonPresenter =
  present: (model) ->
    if model?
      name = "#{model.get("firstname")} #{model.get("lastname")}"
    else
      name = I18n.t("unknown_person")
    r =
      name: name

AirfieldPresenter =
  present: (model) ->
    if model.get("registration")? && model.get("registration") != ""
      model.get("registration")
    else
      model.get("name")

Util =
  intTimeToString: (i) ->
    if i < 0
      "--:--"
    else
      m = i % 60
      if m < 10
        "#{Math.floor(i / 60)}:0#{m}"
      else
        "#{Math.floor(i / 60)}:#{m}"
