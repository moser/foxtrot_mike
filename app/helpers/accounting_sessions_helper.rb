module AccountingSessionsHelper
  def format_accounting_entry(e)
    render partial: 'accounting_entries/show', locals: { accounting_entry: e }, formats: [:html]
  end
end
