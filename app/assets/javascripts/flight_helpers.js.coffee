class List
  constructor: (@resource, @method, @prototype = Object.prototype) ->
    @list = []
  find: (str, flight) ->
    f = (obj) ->
      obj.term = str
      obj
    f obj for obj in @list when this.extract(obj).match(new RegExp(".*#{str}.*", "i"))
  extract: (obj) ->
    if $.isFunction(obj[@method])
      obj[@method].call(obj)
    else
      obj[@method]
  load: ->
    self = this
    $.get self.resource, (data) ->
      self.list = data
      if($.isArray(self.list))
        self.list = (self.createObj(obj) for obj in self.list)
  get: (id) ->
    (obj for obj in @list when obj.id == id)[0]
  createObj: (obj) ->
    newObj = Object.create(@prototype)
    newObj[prop] = obj[prop] for prop of obj when obj.hasOwnProperty(prop)
    newObj
  all: ->
    @list

peopleList = new List("/people.json", "name", { name: -> "#{@firstname} #{@lastname}" })
planesList = new List("/planes.json", "registration")
airfieldsList = new List("/airfields.json", "name")

class TowPlanesList
  constructor: (@list) -> 1
  get: (id) ->
    @list.find(id)
  find: (str, flight) ->
    obj for obj in @list.find(str, flight) when obj.can_tow

towPlanesList = new TowPlanesList(planesList)

class PeopleListWithUnknown
  constructor: (@wrapped_list) ->
    @unknown = null
  load: ->
    self = this
    $.get "/unknown_person.json", (data) ->
      self.unknown = self.wrapped_list.createObj(data)
  get: (id) ->
    if id == "unknown"
      @unknown
    else
      @wrapped_list.get(id)
  find: (str, flight) ->
    l = @wrapped_list.find(str, flight)
    if @unknown.name().match(new RegExp(".*#{str}.*", "i"))
      @unknown.term = str
      @unknown.level = 1
      l.push @unknown
    l
  all: ->
    @wrapped_list.list

peopleListWithUnknown = new PeopleListWithUnknown(peopleList)

class PeopleListWithN
  constructor: (@wrapped_list) ->
    self = this
    f = (n) ->
      self.wrapped_list.createObj({ id: "+#{n}", firstname: "+#{n}", lastname: "", n: n })
    @internal = (f n for n in [1..3])
  get: (id) ->
    @wrapped_list.get(id) || (obj for obj in @internal when obj.id == id)[0]
  find: (str, flight) ->
    if str.match(/^\+.*/)
      plane = planesList.get(flight.data("plane_id"))
      if plane?
        obj for obj in @internal when (plane.seat_count - 1) >= obj.n
      else
        @internal
    else
      @wrapped_list.find(str, flight)
  all: ->
    @wrapped_list.list

peopleListWithN = new PeopleListWithN(peopleList)

levelToI = (a) ->
  { instructor: 0, normal: 1, trainee: 2 }[a]

levelIToGerman = (a) ->
  [ "Lehrer", "Scheininhaber", "Schüler" ][a]

class PeopleList
  constructor: (@list, @method) ->
    @legal_plane_class_id = -1
    @departure_date = null
  get: (id) ->
    @list.get(id)
  find: (str, flight) ->
    self = this
    if flight.data("plane_id") != "" && (@legal_plane_class_id != planesList.get(flight.data("plane_id")).legal_plane_class_id || !@departure_date? || @departure_date != Parse.date(flight.find("#flight_departure_date").val()))
      @legal_plane_class_id = planesList.get(flight.data("plane_id")).legal_plane_class_id
      @departure_date = Parse.date(flight.find("#flight_departure_date").val())
      #TODO sort and set level
      lala = (person) ->
        levels = (levelToI(license.level) for license in person.licenses when (!license.valid_from? || Parse.date_to_s(license.valid_from) <= self.departure_date) && (!license.valid_to? || Parse.date_to_s(license.valid_to?) >= self.departure_date) &&  $.inArray(self.legal_plane_class_id, license.legal_plane_class_ids) > -1)
        if levels.length > 0
          person.level = levels.sort()[levels.length - 1]
        else
          person.level = 2
      lala person for person in @list.all()
    @list.find(str, flight).sort (a, b) ->
      r = 0
      if self.method == "seat2"
        r = a.level - b.level
      if r == 0
        r = (a.lastname.toLowerCase() > b.lastname.toLowerCase()) * 2 - 1
      if a.lastname == b.lastname
        r = (a.firstname.toLowerCase() > b.firstname.toLowerCase()) * 2 - 1
      r


class FieldHelper
  constructor: (@list, el, @field, @method, render = null, required = true, @prefix = "flight") ->
    self = this
    console.log @id()
    @flight_div = $(el)
    @flight_div.data("#{@field}_id", @flight_div.find("##{@id()}").val())
    @old_item = @list.get(@flight_div.data("#{@field}_id"))
    @hidden_element = $("<input type=\"hidden\" id=\"#{@id()}\" name=\"#{@prefix}[#{@field}_id]\" />") .val(@flight_div.find("##{@id()}").val())
    @element = $("<input type=\"text\" id=\"#{@name()}\" name=\"ignore\"/>").autocomplete(
      autoFocus: true
      minLength: 0
      source: (request, response) ->
        response(self.list.find(request.term, self.flight_div))
      select: (event, ui) ->
        self.old_item = ui.item
        self.element.val(self.extract(ui.item))
        self.hidden_element.val(ui.item.id)
        self.flight_div.data("#{self.field}_id", ui.item.id)
        false
      change: (event, ui) ->
        if !ui.item?
          if required
            self.element.autocomplete("option", "select")(event, { item: self.old_item })
          else
            self.old_item = null
            self.element.val("")
            self.hidden_element.val("")
            self.flight_div.data("#{self.field}_id", "")
        false
    ).val(@flight_div.find("##{@id()} option:selected").html())
    @element.data("autocomplete")._renderItem = render || (ul, item) ->
      $("<li></li>")
        .data("item.autocomplete", item)
        .append("<a>#{self.extract(item).replace(new RegExp("(#{item.term})", "gi"), "<b>$1</b>")}</a>")
        .appendTo(ul)
    @flight_div.find("##{@id()}").after(@element).replaceWith(@hidden_element)
  id: ->
    @id_cache ||= "#{@prefix}_#{@field}_id".replace(/[\[\]]/g, "_").replace(/__/g, "_")
  name: ->
    @name_cache ||= @id().substring(0, @id().length - 4)
  extract: (obj) ->
    if $.isFunction(obj[@method])
      obj[@method].call(obj)
    else
      obj[@method]

class @PlaneHelper extends FieldHelper
  constructor: (el, prefix = "flight", list = planesList) ->
    super(list, el, "plane", "registration", ((ul, item) ->
      $("<li></li>")
        .data("item.autocomplete", item)
        .append("<a>#{item.registration.replace(new RegExp("(#{item.term})", "gi"), "<b>$1</b>")}<span class=\"info\">#{item.make}, #{item.group_name}</span></a>")
        .appendTo(ul)
    ), true, prefix)

class @TowPlaneHelper extends PlaneHelper
  constructor: (el) ->
    super(el, "launch[tow_flight]", towPlanesList)

class @AirfieldHelper extends FieldHelper
  constructor: (el, field, prefix = "flight") ->
    super(airfieldsList, el, field, "name", null, true, prefix)

class @PersonHelper extends FieldHelper
  constructor: (el, field, render = null, required = true, prefix = "flight", list = peopleList) ->
    super(list, el, field, "name", render, required, prefix)

class @CrewMemberHelper extends PersonHelper
  constructor: (el, field, required = true, prefix = "flight", list = peopleList) ->
    render = (ul, item) ->
      str = "<a>#{item.name().replace(new RegExp("(#{item.term})", "gi"), "<b>$1</b>")}"
      str += "<span class=\"info\">#{levelIToGerman(item.level)}, #{item.group_name}</span>" if item.level?
      str += "</a>"
      $("<li></li>")
       .data("item.autocomplete", item)
       .append(str)
       .appendTo(ul)
    super(el, field, render, required, prefix, new PeopleList(list, field))

class @CrewHelper
  constructor: (el, prefix = "flight") ->
    new CrewMemberHelper(el, "seat1", true, prefix, peopleListWithUnknown)
    new CrewMemberHelper(el, "seat2", false, prefix, peopleListWithN)

$ ->
  if document.location.pathname.match("^/flights")?
    peopleList.load()
    planesList.load()
    airfieldsList.load()
    peopleListWithUnknown.load()
