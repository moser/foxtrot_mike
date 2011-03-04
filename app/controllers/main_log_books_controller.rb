class MainLogBooksController < ApplicationController
  javascript :timepicker
  def show
    @airfield = Airfield.find(params[:airfield_id])
    @date = parse_date(params[:filter], :date) || AbstractFlight.latest_departure(@airfield.flights).to_date
    @flights = @airfield.flights.where(AbstractFlight.arel_table[:departure].gteq(@date.to_datetime)).
                       where(AbstractFlight.arel_table[:departure].lt((@date + 1.day).to_datetime)).
                       order("departure ASC").all
    if params[:as] == 'controller_log'
      javascript :controller_log
      @controllers = []
      if @flights.count > 0
        c = nil
        @flights.each do |f|
          if c != f.controller
            c = f.controller
            if @controllers.last
              @controllers.last[:to] = f.departure
            end
            @controllers << { :person => f.controller, :from => f.departure, :to => f.departure }
          end
        end
        @controllers.last[:to] = (@flights.map(&:arrival).select { |a| !a.nil? }).max
      end
      template = "main_log_books/controller_log"
      orientation = "Portrait"
    else
      template = "main_log_books/show"
      orientation = "Landscape"
    end
    
    respond_to do |f|
      f.pdf do
        render :pdf => "".downcase.gsub(" ", "-"), 
    				   :template => "#{template}.html.haml",
    				   :orientation => orientation,
    				   :disable_internal_links => true,
    				   :disable_external_links => true
  		end
      f.html { render :template => template }
    end
  end
end
