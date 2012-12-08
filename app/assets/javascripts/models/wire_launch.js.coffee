class Flights.Models.WireLaunch extends Flights.BaseModel
  paramRoot: 'wire_launch'
  defaults:
    editable: true

  wire_launcher: ->
    if @get("wire_launcher_id")?
      Flights.wire_launchers.get(@get("wire_launcher_id"))

  operator: ->
    if @get("operator_id")?
      Flights.people.get(@get("operator_id"))
