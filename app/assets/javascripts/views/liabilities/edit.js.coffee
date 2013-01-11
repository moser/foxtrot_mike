class F.Views.Liabilities.Edit extends F.ModelBasedView
  className: "edit_liability"
  tagName: "tr"
  templateName: "liabilities/form"

  events:
    'focus input.edit_field': 'edit_field'
    'change input': 'change'
    'click a.save': 'save'
    'click a.cancel': 'reset'

  edit_field: (e) ->
    target = @$(e.target)
    unless target.siblings(".searchParent").length > 0
      present = (p) -> F.Presenters.Person.present(p)
      params =
        list: F.people.models
        label: (p) -> present(p).name
        score: (p) -> "#{1} #{present(p).lastname} #{present(p).firstname}"
        match: (p, q) -> present(p).name.toLowerCase().indexOf(q.toLowerCase()) > -1
        for: @$(e.target).siblings("input[name=person_id]")
        span: @$(e.target)
      target.data("searchParent", c = new F.Views.SearchParent(params))
      target.before(c.$el)
    else
      target.data("searchParent").release()
    false

  update_model: ->
    @model.set(proportion: parseInt(@$("input[name=proportion]").val()), person_id: @$("input[name=person_id]").val())

  save: =>
    @update_model()
    if @model.valid()
      @model.save()
      @hide()
    else
      @markInvalid()

  reset: =>
    if @model.id?
      @model.reset()
    else
      @model.destroy()
    @hide()

  hide: =>
    @stopListening()
    @$el.remove()
    @parent.show()

  destroy: =>
    @stopListening()

  initialize: ->
    super()
    @parent = @options.parent
    @listenTo(@model, "change", @updateView)
    @listenTo(@options.collection, "change", @updateView)
    @listenTo(@options.collection, "remove", @updateView)
    @listenTo(@model, "remove", @destroy)
    @render()

  render: ->
    @$el.html(@template({ liability: @model }))
    @updateView()

  updateView: =>
    @$("input[name=person_id]").val(@model.get("person_id"))
    @$("input[name=person_front]").val(if @model.person()? then F.Presenters.Person.present(@model.person()).name else "")
    @$("input[name=proportion]").val(@model.get("proportion"))
    @$("td.percentage").html(F.Util.percentageToString(@model.collection.percentage_for(@model)))
    @$("td.value").html(F.Util.currencyToString(@model.collection.percentage_for(@model) * @model.flight().cost_free_sum()))

  markInvalid: =>
    @$(".control-group").removeClass("error")
    @$(".person").addClass("error") unless @model.personValid()
    @$(".proportion").addClass("error") unless @model.proportionValid()
