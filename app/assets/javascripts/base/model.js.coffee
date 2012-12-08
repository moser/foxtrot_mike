class Flights.BaseModel extends Backbone.Model
  updateSaved: ->
    @savedAttributes = _.clone(@attributes)

  reset: ->
    @set(@savedAttributes)

  dirty: ->
    !(_.isEqual(@attributes, @savedAttributes))

  initialize: ->
    super()
    @updateSaved()
    @bind("sync", @updateSaved)
