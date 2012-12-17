class PdfsController < ApplicationController
  def create
    authorize! :read, Flight
    @flights = AbstractFlight.all
    render :pdf => "flights",
           :template => "flights/_grouped.html.haml",
           :disable_internal_links => true,
           :disable_external_links => true,
           :dpi => "90",
           :orientation => "landscape"
  end
end
