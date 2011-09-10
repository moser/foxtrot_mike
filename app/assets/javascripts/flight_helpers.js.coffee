class List
  constructor: (@resource, @method) ->
    @list = []
  find: (str, flight) ->
    f = (obj) ->
      obj.term = str
      obj
    f obj for obj in @list when this.extract(obj).match(new RegExp(".*#{str}.*", "i"))
  extract: (obj) ->
    obj[@method]
  load: ->
    self = this
    $.get self.resource, (data) ->
      self.list = data
  get: (id) ->
    (obj for obj in @list when obj.id == id)[0]

@peopleList = new List("/people.json", "name")
peopleList.load()
planesList = new List("/planes.json", "registration")
airfieldsList = new List("/airfields.json", "name")
planesList.load()
airfieldsList.load()

levelToI = (a) ->
  { instructor: 0, normal: 1, trainee: 2 }[a]

levelIToGerman = (a) ->
  [ "Lehrer", "Scheininhaber", "Schüler" ][a]

class PeopleList
  constructor: (@method) ->
    @legal_plane_class_id = -1
    @departure_date = null
    @list = []
  get: (id) ->
    peopleList.get(id)
  find: (str, flight) ->
    if @legal_plane_class_id != planesList.get(flight.data("plane_id")).legal_plane_class_id || !@departure_date? || @departure_date != Parse.date(flight.find("#flight_departure_date").val())
      @legal_plane_class_id = planesList.get(flight.data("plane_id")).legal_plane_class_id
      self = this
      @departure_date = Parse.date(flight.find("#flight_departure_date").val())
      #TODO sort and set level
      lala = (person) ->
        levels = (levelToI(license.level) for license in person.licenses when (!license.valid_from? || Parse.date_to_s(license.valid_from) <= self.departure_date) && (!license.valid_to? || Parse.date_to_s(license.valid_to?) >= self.departure_date) &&  $.inArray(self.legal_plane_class_id, license.legal_plane_class_ids) > -1)
        if levels.length > 0
          person.level = levels.sort()[levels.length - 1]
        else
          person.level = 2
      lala person for person in peopleList.list
    peopleList.find(str, flight).sort (a, b) ->
      r = 0
      if self.method == "seat2"
        r = a.level - b.level
      if r == 0
        r = (a.lastname.toLowerCase() > b.lastname.toLowerCase()) * 2 - 1
      if a.lastname == b.lastname
        r = (a.firstname.toLowerCase() > b.firstname.toLowerCase()) * 2 - 1
      r


class FieldHelper
  constructor: (@list, el, @field, @method, render = null, required = true) ->
    self = this
    @flight_div = $(el)
    @flight_div.data("#{@field}_id", @flight_div.find("#flight_#{@field}_id").val())
    @old_item = @list.get(@flight_div.data("#{@field}_id"))
    @hidden_element = $("<input type=\"hidden\" id=\"flight_#{@field}_id\" name=\"flight[#{@field}_id]\" />") .val(@flight_div.find("#flight_#{@field}_id").val())
    @element = $("<input type=\"text\" id=\"flight_#{@field}\" name=\"ignore\"/>").autocomplete(
      autoFocus: true
      minLength: 0
      source: (request, response) ->
        response(self.list.find(request.term, self.flight_div))
      select: (event, ui) ->
        self.old_item = ui.item
        self.element.val(ui.item[self.method])
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
    ).val(@flight_div.find("#flight_#{@field}_id option:selected").html())
    @element.data("autocomplete")._renderItem = render || (ul, item) ->
      $("<li></li>")
        .data("item.autocomplete", item)
        .append("<a>#{item[self.method].replace(new RegExp("(#{item.term})", "gi"), "<b>$1</b>")}</a>")
        .appendTo(ul)
    @flight_div.find("#flight_#{@field}_id").after(@element).replaceWith(@hidden_element)

class @PlaneHelper extends FieldHelper
  constructor: (el) ->
    super(planesList, el, "plane", "registration", (ul, item) ->
      $("<li></li>")
        .data("item.autocomplete", item)
        .append("<a>#{item.registration.replace(new RegExp("(#{item.term})", "gi"), "<b>$1</b>")}<span class=\"info\">#{item.make}, #{item.group_name}</span></a>")
        .appendTo(ul)
    )

class @AirfieldHelper extends FieldHelper
  constructor: (el, field) ->
    super(airfieldsList, el, field, "name")

class @PersonHelper extends FieldHelper
  constructor: (el, field, list = peopleList, render = null, required = true) ->
    super(list, el, field, "name", render, required)

class @CrewHelper
  constructor: (el) ->
    render = (ul, item) ->
      $("<li></li>")
       .data("item.autocomplete", item)
       .append("<a>#{item.name.replace(new RegExp("(#{item.term})", "gi"), "<b>$1</b>")}<span class=\"info\">#{levelIToGerman(item.level)}, #{item.group_name}</span></a>")
       .appendTo(ul)
    new PersonHelper(el, "seat1", new PeopleList("seat1"), render)
    new PersonHelper(el, "seat2", new PeopleList("seat2"), render, false)
