class DebitorsController < ApplicationController
  def index
    authorize! :read, :debitors
    render json: Person.debitors
  end
end
