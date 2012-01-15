class MainLogBooksController < ApplicationController

  javascript :timepicker
  def show
    @airfield = Airfield.find(params[:airfield_id])
    authorize! :read, @airfield
    @date = parse_date(params[:filter], :date) || AbstractFlight.latest_departure(@airfield.flights).to_date
    if params[:as] == 'controller_log'
      javascript :controller_log
      controller_log = @airfield.controller_log(@date)
      if params[:from] && params[:to]
        controller_log.merge(params[:from], params[:to])
      end
      @controllers = controller_log.controllers
      template = "main_log_books/controller_log"
      orientation = "Portrait"
    else
      @flights = @airfield.flights.where(:departure_date => @date).order("departure_date ASC, departure_i ASC").all
      template = "main_log_books/show"
      orientation = "Portrait"
    end

    respond_to do |f|
      f.pdf do
        render :pdf => "".downcase.gsub(" ", "-"),
               :template => "#{template}.html.haml",
               :orientation => orientation,
               :disable_internal_links => true,
               :disable_external_links => true,
               :dpi => "90"
      end
      f.html { render :template => template }
    end
  end
end
