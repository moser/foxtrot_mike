module AccountingSessionsHelper
  def format_accounting_entry(e)
    raw "#{link_to("#{e.from}", e.from, :class => "facebox")} / " +
    "#{link_to("#{e.to}", e.to, :class => "facebox") } #{format_currency(e.value)}" +
    (e.manual? ? e.text : "")
  end
end
