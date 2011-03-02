module AccountingSessionsHelper
  def format_accounting_entry(from, to, value)
   content_tag(:div, :class => :accounting_entry) do 
     I18n.t("views.accounting_entry", :from => from, :to => to, :value => format_currency(value))
   end
  end
end
