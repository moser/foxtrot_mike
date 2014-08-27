F.Models.Airfield = Backbone.Model.extend
  paramRoot: 'airfield'

F.Collections.Airfields = Backbone.Collection.extend
  model: F.Models.Airfield
  url: '/airfields?deleted=false'

  firstHomeAirfieldId: ->
    h = _(@where(home: true)).first()
    if h?
      h.id
    else
      ""
