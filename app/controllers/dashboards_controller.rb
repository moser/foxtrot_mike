class DashboardsController < ApplicationController
  def show
    authorize! :read, :dashboards
    @current_person = (current_account && current_account.person)
    @licenses = @current_person.licenses if @current_person
    @planes = @current_person.group.planes if @current_person
    @groups = Group.all
  end
end
