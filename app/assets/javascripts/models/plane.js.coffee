F.Models.Plane = Backbone.Model.extend
  paramRoot: 'plane'

F.Collections.Planes = Backbone.Collection.extend
  model: F.Models.Plane
  url: '/planes'
