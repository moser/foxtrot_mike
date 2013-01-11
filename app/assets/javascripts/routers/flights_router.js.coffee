F.Routers.FlightsRouter = Backbone.Router.extend
  routes:
    "flights": "showIndex"
    ":filter_resource/:filter_id/flights": "showIndex"
    ":filter_resource/:filter_id/flights/range/:range": "showIndex"
    "flights/:id": "show"

  showIndex: (filter_resource, filter_id, range)->
    @index = new F.Views.Flights.Index(el: $('.app_container'), filter: { resource: filter_resource, id: filter_id }, range: range)

  show: (id) ->
    unless @index?
      @showIndex()
    @index.show(id)
