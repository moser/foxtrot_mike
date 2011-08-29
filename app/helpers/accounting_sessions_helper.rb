module AccountingSessionsHelper
  def format_accounting_entry(from, to, value)
   content_tag(:div, :class => :accounting_entry) do 
     I18n.t("views.accounting_entry", :from => link_to(from, from, :class => "facebox"), :to => link_to(to, to, :class => "facebox"), :value => format_currency(value)).html_safe
   end
  end
end
