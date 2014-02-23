F.Models.Airfield = Backbone.Model.extend
  paramRoot: 'airfield'
  toString: ->
    if @get("registration")? && @get("registration") != ""
      "#{@get("name")} (#{@get("registration")})"
    else
      @get("name")

F.Collections.Airfields = Backbone.Collection.extend
  model: F.Models.Airfield
  url: '/airfields'

  firstHomeAirfieldId: ->
    h = _(@where(home: true)).first()
    if h?
      h.id
    else
      ""
