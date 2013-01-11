class F.Views.Liabilities.Index extends F.TemplateView
  className: 'liabilities'
  templateName: 'liabilities/index'

  events:
    "click a.new": "new"

  checkDefault: =>
    if @collection.length == 0
      @$("tr.default").show()
    else
      @$("tr.default").hide()

  new: =>
    @collection.add(new F.Models.Liability(flight_id: @flight.id))

  add: (model) =>
    @$("tbody").append (@views[model.cid] = new F.Views.Liabilities.Show({ model: model, collection: @collection })).el
    @views[model.cid].render()
    @views[model.cid].edit()
    @checkDefault()

  remove: (model) =>
    view = @views[model.cid]
    view.remove()
    view.$el.remove()
    @views[model.cid] = null
    @checkDefault()
  
  initialize: ->
    super()
    @flight = @options.flight
    @flight.on("sync", (=> @render(); @checkDefault()))
    @collection = @options.collection
    @collection.on("change", @change)
    @collection.on("add", @add)
    @collection.on("remove", @remove)
    @views = {}
    @render()
    @checkDefault()

  render: ->
    @$el.html(@template({ flight: @flight }))
    @collection.each (e) =>
      @$("tbody").append (@views[e.cid] = new F.Views.Liabilities.Show({ model: e, collection: @collection })).el
      @views[e.cid].render()
