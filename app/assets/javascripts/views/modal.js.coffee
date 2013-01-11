class Modal extends F.TemplateView
  initialize: ->
    @render()
    @$el.modal()

  render: ->
    @setElement(@template({ info: @model.info }))

  hide: ->
    @$el.modal("hide")
    @remove()

class F.Views.CancelResetSaveDialogView extends Modal
  templateName: "dialog/cancel_reset_save"
  events:
    "click a.cancel": "cancel"
    "click a.reset": "reset"
    "click a.save": "save"

  cancel: ->
    @hide()
    false

  reset: ->
    @model.reset? && @model.reset()
    @hide()
    false

  save: ->
    @model.save? && @model.save()
    @hide()
    false

class F.Views.YesNo extends Modal
  templateName: "dialog/yes_no"
  events:
    "click a.yes": "yes"
    "click a.no": "no"

  yes: ->
    @model.yes? && @model.yes()
    @hide()
    false

  no: ->
    @model.no? && @model.no()
    @hide()
    false
