class ValidFromValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.valid_from_changed? && !value.nil? && value <= AccountingSession.latest_finished_session_end
      record.errors.add attribute,
                        (options[:message] ||
                         I18n.t("activerecord.errors.messages.greater_than", 
                                :count => I18n.l(AccountingSession.latest_finished_session_end)))
    end
  end
end
