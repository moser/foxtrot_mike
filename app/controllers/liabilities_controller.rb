class LiabilitiesController < ResourceController
  #before_filter :login_required  
  nested :flight

  def destroy
    model_by_id
    @nested = Flight.find(params[:flight_id])
    @model.destroy
    respond_to do |format|
      format.json { head :ok }
    end
  end  
end
