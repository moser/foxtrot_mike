class Flights.Views.SearchParent extends Backbone.View
  className: "searchParent"
  events:
    "keydown input.search": "keydown"
    "keyup input.search": "keyup"
    "click li.result": "selectByClick"

  selectByClick: (e) =>
    @selected = @listFindById(@$(e.target).attr("data-id"))
    @blur()

  keydown: (e) =>
    switch e.keyCode
      when 27 #ESC
        @selected = @old
        @blur()
      when 13 #ENTER
        e.preventDefault()
        @blur()
      when 9
        @blur()
  
  keyup: (e) =>
    switch e.keyCode
      when 38, 33 #UP
        if @results.length > 1
          @selected = @results[(@results.length + @results.indexOf(@selected) - 1) % @results.length]
          @renderList()
      when 40, 34 #DOWN
        if @results.length > 1
          @selected = @results[(@results.length + @results.indexOf(@selected) + 1) % @results.length]
          @renderList()
      else
        if @filter != @$(".search").val()
          @filter = @$(".search").val()
          @results = (p for p in @list when @match(p, @filter))
          if @results.indexOf(@old) > 0
            @selected = @old
          else if @results.length > 0
            @selected = @results[0]
          else
            @selected = null
          @renderList()

  blur: =>
    $("#block").remove()
    @select(@selected)
    @release()


  release: =>
    @$el.detach()

  select: (i) =>
    if i
      @for.val(i.id)
      @span.val(@label(i))
      @callback(i) if @callback && i != @old

  renderList: =>
    sorted_results = _.sortBy @results, @score, @
    @$("ul.results").html(JST["searchParent/results"](results: sorted_results, label: @label, selected: @selected))
    window.setTimeout((=> @$("li.result.ui-widget-header").scrollintoview({offset: 50})), 100)
      
  listFindById: (id) =>
    (x for x in @list when x.id == id)[0]

  initialize: ->
    [@for, @span, @list, @label, @match, @score, @callback] = [@options.for, @options.span, @options.list, @options.label, @options.match, @options.score, @options.callback]
    throw "@for, @span, @list, @label, @match, @score are needed" unless @for && @span && @list && @label && @match && @score
    @filter = ""
    @results = @list
    @old = @listFindById(@for.val())
    #@$(".search").val(@label(@old)) #TODO
    if @old
      @selected = @old
    else if @list.length > 0
      @selected = @results[0]
    else
      @selected = null
    $("body").append($('<div id="block" />').click(=> @selected = @old; @blur()))
    @render()
    @renderList()

  render: =>
    @$el.html JST["searchParent/show"](flight: @flight)
    @$el.addClass("ui-widget ui-widget-content ui-helper-clearfix ui-corner-all")
    window.setTimeout((=> @$(".search").focus()), 100)
