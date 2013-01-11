F.Models.Airfield = Backbone.Model.extend
  paramRoot: 'airfield'

F.Collections.Airfields = Backbone.Collection.extend
  model: F.Models.Airfield
  url: '/airfields'
