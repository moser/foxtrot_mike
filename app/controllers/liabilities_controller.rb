class LiabilitiesController < ResourceController
  #before_filter :login_required  
  nested :flight

  def destroy
    model_by_id
    @nested = Flight.find(params[:flight_id])
    @model.destroy
    redirect_to(flight_liabilities_path(@nested))
  end  
end
