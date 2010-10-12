class DashboardsController < ApplicationController
  def show
    @current_person = (current_account && current_account.person) || Person.first #TODO HACK
    @licenses = @current_person.licenses
    @planes = @current_person.group.planes
  end
end
