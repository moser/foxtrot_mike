module AccountsHelper
  def link_to_current_account
    link_to current_account.login, current_account
  end
end
