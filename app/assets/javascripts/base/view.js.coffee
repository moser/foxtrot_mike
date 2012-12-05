
class Flights.BaseView extends Backbone.View

class Flights.TemplateView extends Flights.BaseView
  template: (o) ->
    if @templateName
      JST[@templateName](o)
    else
      throw "templateName not defined"

class Flights.ModelBasedView extends Flights.TemplateView
  dirty: ->
    @model.dirty

  change: ->
    @update_model()
    @trigger("changed")

  update_model: ->
    throw "Thou shalt implement #update_model"
