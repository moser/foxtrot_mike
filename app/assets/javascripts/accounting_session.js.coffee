$ ->
  if $(".accounting_session").length > 0
    $("a.toggle_accounting_entries").click ->
      $(this).siblings(".accounting_entries").toggle()
      false

    filter = []
    $("a.toggle_filter").click ->
      v = $(this).data('filter')
      $(this).parent().toggleClass("filtering")
      if $.inArray(v, filter) >= 0
        filter = filter.remove(v)
      else
        filter.push v
      if filter.length > 0
        $(".flight").addClass "hidden"
        $.each filter, (i, e) ->
          $(".flight.filter-" + e).removeClass "hidden"
      else
        $(".flight").removeClass "hidden"
      false
