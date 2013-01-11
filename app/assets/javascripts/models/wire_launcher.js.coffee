class F.Models.WireLauncher extends F.BaseModel
  paramRoot: 'wire_launcher'

F.Collections.WireLaunchers = Backbone.Collection.extend
  model: F.Models.WireLauncher
  url: '/wire_launchers'
