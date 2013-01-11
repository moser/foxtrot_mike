class F.Views.Liabilities.Show extends F.TemplateView
  className: "liability"
  tagName: "tr"
  templateName: "liabilities/show"

  events:
    'click a.edit': 'edit'
    'click a.destroy': 'destroy'

  edit: ->
    unless @editView?
      @editView = new F.Views.Liabilities.Edit(model: @model, collection: @collection, parent: @)
      @$el.hide().after(@editView.el)

  destroy: =>
    @stopListening()
    @model.destroy()

  show: =>
    @editView = null
    @$el.show()

  remove: (model) =>
    unless model == @model
      @updateView()
    else
      @stopListening()

  initialize: ->
    super()
    @listenTo(@options.collection, "add", @updateView)
    @listenTo(@options.collection, "change", @updateView)
    @listenTo(@options.collection, "remove", @remove)
    @model = @options.model
    @render()

  render: ->
    @$el.html(@template({ liability: @model }))
    @updateView()

  updateView: ->
    @$("td.person").html(F.Presenters.Person.present(@model.person()).name)
    @$("td.proportion").html(@model.get("proportion"))
    @$("td.percentage").html(F.Util.percentageToString(@model.collection.percentage_for(@model)))
    @$("td.value").html(F.Util.currencyToString(@model.collection.percentage_for(@model) * @model.flight().cost_free_sum()))
