F.Models.CostHint = Backbone.Model.extend
  paramRoot: 'cost_hint'

  present: ->
    r =
      name: @get("name")
      id: @id

F.Collections.CostHints = Backbone.Collection.extend
  model: F.Models.CostHint
  url: '/cost_hints'

class F.Models.NoCostHint
  constructor: ->
    @name = @id = "-"
  present: ->
    @
