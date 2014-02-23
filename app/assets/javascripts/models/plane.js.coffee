F.Models.Plane = Backbone.Model.extend
  paramRoot: 'plane'
  toString: -> @get("registration")

F.Collections.Planes = Backbone.Collection.extend
  model: F.Models.Plane
  url: '/planes'
