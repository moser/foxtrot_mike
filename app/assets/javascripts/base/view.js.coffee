class F.BaseView extends Backbone.View

class F.TemplateView extends F.BaseView
  template: (o) ->
    if @templateName
      JST[@templateName](o)
    else
      throw "templateName not defined"

class F.ModelBasedView extends F.TemplateView
  dirty: ->
    @model.dirty()

  change: ->
    @update_model()
    @trigger("changed")

  update_model: ->
    throw "Thou shalt implement #update_model"

  initialize: ->
    @model = @options.model
    @model.on("sync", => @trigger("changed"))

class F.Modal extends F.TemplateView
  initialize: ->
    @render()
    @$el.modal()

  render: ->
    @setElement(@template({ info: @model.info }))

  hide: ->
    @$el.modal("hide")
    @remove()
