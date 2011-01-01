class DashboardsController < ApplicationController
  def show
    authorize! :read, :dashboards
    @current_person = (current_account && current_account.person)
    @licenses = @current_person.licenses
    @planes = @current_person.group.planes
  end
end
