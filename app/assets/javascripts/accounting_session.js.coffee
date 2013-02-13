$ ->
  if $(".accounting_session").length > 0
    $("a.toggle_accounting_entries").click ->
      $(this).parents('.aggregated_entry').siblings(".accounting_entry.#{$(this).attr('data-id')}").toggle()
      false
    $("a.toggle_filter").click ->
      parent = $(this).parents('.aggregated_entry').toggleClass("filtering")
      $(".flight").removeClass "filtering"
      if parent.hasClass("filtering")
        $(".flight.filter-" + $(this).data("filter")).addClass "filtering"
      $(".aggregated_entry:not(##{parent.attr("id")})").removeClass "filtering"
      $(".child_entry").removeClass "filtering"
      false
    $("a.toggle_filter_id").click ->
      parent = $(this).parents('.accounting_entry').toggleClass("filtering")
      $(".flight").removeClass "filtering"
      if parent.hasClass("filtering")
        $(".flight.e-" + parent.attr("id")).addClass "filtering"
      $(".aggregated_entry").removeClass "filtering"
      $(".child_entry:not(##{parent.attr("id")})").removeClass "filtering"
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
