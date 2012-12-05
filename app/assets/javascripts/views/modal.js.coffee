class Flights.Views.CancelResetSaveDialogView extends Flights.TemplateView
  templateName: "dialog/show"
  events:
    "click a.cancel": "cancel"
    "click a.reset": "reset"
    "click a.save": "save"

  cancel: ->
    @$el.modal("hide")
    @$el.remove()
    false

  reset: ->
    @model.reset? && @model.reset()
    @cancel()
    false

  save: ->
    @model.save? && @model.save()
    @cancel()
    false

  initialize: ->
    @render()
    @$el.modal()

  render: ->
    @setElement(@template({ info: @model.info }))
