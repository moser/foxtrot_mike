class Flights.BaseModel extends Backbone.Model
  markDirty: ->
    if @hasChanged()
      @idirty = true

  unmarkDirty: ->
    @idirty = false

  updateSaved: ->
    @savedAttributes = _.clone(@attributes)

  reset: ->
    @set(@savedAttributes)
    @idirty = false

  dirty: ->
    @idirty

  initialize: ->
    @updateSaved()
    @on("change", @markDirty)
    @on("sync", @unmarkDirty)
    @on("sync", @updateSaved)
