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
  $(".new_manual_accounting_entry td.clickable").click ->
    a = $(this).parent().find("input[type=checkbox]")
    a.attr("checked", (typeof a.attr("checked")) == "undefined")
  if $("form.accounting_session").length > 0
    $("#accounting_session_bank_debit").change ->
      $("#accounting_session_without_flights").attr("disabled", $(this).is(":checked")).attr("checked", $(this).is(":checked"))
      $("#accounting_session_start_date").attr("disabled", $(this).is(":checked"))
      $("#accounting_session_end_date").attr("disabled", $(this).is(":checked"))
      $("#accounting_session_credit_financial_account_id").attr("disabled", !$(this).is(":checked"))
    $("#accounting_session_without_flights").change ->
      $("#accounting_session_start_date").attr("disabled", $(this).is(":checked"))
      $("#accounting_session_end_date").attr("disabled", $(this).is(":checked"))
