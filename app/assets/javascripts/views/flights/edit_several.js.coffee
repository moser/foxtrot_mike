class F.Views.Flights.EditSeveral extends F.Modal
  className: "edit_several"
  templateName: "dialog/edit_several"
  events:
    "click .cancel": "cancel"

  cancel: (e) ->
    @hide()

  initialize: (options) ->
    super(options)
    @model = options.model
    @model.editable = (v) -> true

  render: ->
    @$el.html(@template({ model: { editable: (x) -> true } }))
    @updateView()

  updateView: ->
    @updateViewDepartureDate()
    @updateViewField('plane')
    @updateViewField('seat1_person')
    @updateViewSeat2()
    @updateViewField('from')
    @updateViewField('to')
    @updateViewField('controller')
    @updateViewField('cost_hint')
    #@$("textarea[name=comment]").val(p.comment_long)

  updateViewDepartureDate: () ->
    @$("input[name=departure_date_front]").datepicker(dateFormat: I18n.t("date.formats.js.default"), altField: "input[name=departure_date]", altFormat: "yy-mm-dd")
    @$("input[name=departure_date]").val(Format.date_to_s(@model.get('departure_date')))
    @$("input[name=departure_date_front]").val(Format.date_short(@model.get('departure_date')))
    @decorateViewField('departure_date')

  updateViewSeat2: () ->
    obj = @model.get('seat2_person')
    if (n = @model.get("seat2_n")) > 0 && !obj?
      obj ||= { id: "+#{n}", toString: -> "+#{n}" }
    obj ||= { id: '', toString: -> '' }
    @$("input[name=seat2_id]").val(obj.id)
    @$("input[name=seat2_front]").val(obj.toString())
    @decorateViewField('seat2')
  
  updateViewField: (attr) ->
    obj = @model.get(attr)
    obj ||= { id: '', toString: -> '' }
    @$("input[name=#{attr}_id]").val(obj.id)
    @$("input[name=#{attr}_front]").val(obj.toString())
    @decorateViewField(attr)

  decorateViewField: (attr) ->
    unless @model.identical(attr)
      @$(".control-group.#{attr}").addClass('danger')
    unless @model.possible(attr)
      @$("input[name=#{attr}_front]").attr('disabled', 'disabled')
      @$(".control-group.#{attr}").addClass('disabled')
