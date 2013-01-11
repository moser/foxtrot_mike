class F.Views.WireLaunches.Edit extends F.ModelBasedView
  className: "edit_wire_launch"
  templateName: "flights/edit_wire_launch"
  
  events:
    'change input': 'change'
    'focus input.edit_field': 'edit_field'

  edit_field: (e) ->
    target = @$(e.target)
    field = target.attr("data-edit")
    unless target.siblings(".searchParent").length > 0
      switch field
        when "wire_launcher"
          params =
            list: F.wire_launchers.models
            label: (p) -> p.get("registration")
            score: (p) -> 1
            match: (p, q) -> p.get("registration").toLowerCase().indexOf(q.toLowerCase()) > -1
        when "operator"
          present = (p) -> F.Presenters.Person.present(p)
          params =
            list: F.people.models
            label: (p) -> present(p).name
            score: (p) -> "#{1} #{present(p).lastname} #{present(p).firstname}"
            match: (p, q) -> present(p).name.toLowerCase().indexOf(q.toLowerCase()) > -1
      params["for"] = @$(e.target).siblings("input[name=#{field}_id]")
      params["span"] = @$(e.target)
      params["callback"] = => @change()
      target.data("searchParent", c = new F.Views.SearchParent(params))
      target.before(c.$el)
    else
      target.data("searchParent").release()
    false

  update_model: ->
    attr = {}
    _.each [ "wire_launcher_id", "operator_id" ], ((f) ->
               if @$("input[name=#{f}]").length > 0
                 attr[f] = @$("input[name=#{f}]").val()), @
    @model.set(attr)

  initialize: ->
    super()
    @render()

  render: ->
    @$el.html(@template({ wire_launch: F.Presenters.WireLaunch.present(@model) }))
