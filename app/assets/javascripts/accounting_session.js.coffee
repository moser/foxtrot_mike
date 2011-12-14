$ ->
  if $(".accounting_session").length > 0
    $("a.toggle_accounting_entries").click ->
      $(this).siblings(".accounting_entries").toggle()
      false
    $("a.toggle_filter").click ->
      $(this).parent().toggleClass("filtering")
      $(".flight").removeClass "filtering"
      if $(this).parent().hasClass("filtering")
        $(".flight.filter-" + $(this).data("filter")).addClass "filtering"
      $(".aggregated_entry:not(##{$(this).parent().attr("id")})").removeClass "filtering"
      $(".entry").removeClass "filtering"
      false
    $("a.toggle_filter_id").click ->
      $(this).parent().toggleClass("filtering")
      $(".flight").removeClass "filtering"
      if $(this).parent().hasClass("filtering")
        $(".flight.e-" + $(this).parent().attr("id")).addClass "filtering"
      $(".aggregated_entry").removeClass "filtering"
      $(".entry:not(##{$(this).parent().attr("id")})").removeClass "filtering"
      false
