class DuplicateDashboardController < ApplicationController
  def show
    authorize! :update, Person
    authorize! :update, Airfield
    authorize! :update, Plane
    @from = params[:from] || 30.days.ago.to_date
    @to = params[:to] || 0.days.ago.to_date
    @people = Person.where("created_at BETWEEN ? AND ?", @from, @to).where(duplicate_of_id: nil).all
    @airfields = Airfield.where("created_at BETWEEN ? AND ?", @from, @to).where(duplicate_of_id: nil).all
    @planes = Plane.where("created_at BETWEEN ? AND ?", @from, @to).where(duplicate_of_id: nil).all
  end
end
