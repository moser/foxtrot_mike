class F.Models.WireLaunch extends F.BaseModel
  paramRoot: 'wire_launch'
  defaults:
    editable: true

  wire_launcher: ->
    if @get("wire_launcher_id")?
      F.wire_launchers.get(@get("wire_launcher_id"))

  operator: ->
    if @get("operator_id")?
      F.people.get(@get("operator_id"))

  cost_free_sum: ->
    if @cost()?
      @cost().free_sum
    else
      0

  cost: ->
    @get("cost")
