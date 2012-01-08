class DestroyConfirmationsController < ApplicationController
  def new
    @obj = parent
    authorize! :destroy, @obj
    render :layout => !request.xhr?
  end

  def create
    @obj = parent
    authorize! :destroy, @obj
    if @obj.destroy
      unless request.xhr?
        redirect_to @obj.class
      else
        head :ok
      end
    else
      redirect_to "/403.html"
    end
  end

private
  def parent
    [ :flight ].each do |o|
      return o.to_s.camelcase.constantize.find(params["#{o}_id"]) if params["#{o}_id"]
    end
  end
end
