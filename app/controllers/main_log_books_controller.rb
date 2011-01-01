class MainLogBooksController < ApplicationController
  javascript :timepicker
  def show
    @airfield = Airfield.find(params[:airfield_id])
    @date = parse_date(params[:filter], :date) || Flight.latest_departure(@airfield.flights).to_date
    @flights = @airfield.flights.where(Flight.arel_table[:departure].gteq(@date.to_datetime)).
                       where(Flight.arel_table[:departure].lt((@date + 1.day).to_datetime)).
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
      render :template => "main_log_books/controller_log"
    end
  end
end
