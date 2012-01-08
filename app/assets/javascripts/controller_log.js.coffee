$ ->
  $(".linked").live "change", (e) ->
    elem = $(e.target)
    if Parse.time(elem.val())
      $(".linked[data-link-group=#{elem.data("link-group")}]").val(elem.val())
  $(".cl_change_params").live "click", (e) ->
    from = []
    to = []
    $(".controllers input.from").each (i, el) ->
      from.push $(el).val()
    $(".controllers input.to").each (i, el) ->
      to.push $(el).val()
    uri = parseUri(@href)
    console.log(from)
    console.log(to)
    uri.params.from = from
    uri.params.to = to
    href = uri.reconstruct()
    console.log(href)
    document.location = href
    false
