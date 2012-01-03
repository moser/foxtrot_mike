module AccountingSessionsHelper
  def format_accounting_entry(from, to, value)
   I18n.t("views.accounting_entry", :from => link_to("#{from} (#{from.number})", from, :class => "facebox") , :to => link_to("#{to} (#{to.number})", to, :class => "facebox"), :value => format_currency(value)).html_safe
  end
end
