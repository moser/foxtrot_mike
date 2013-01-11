class FlightsController < ApplicationController
  def index
    authorize! :read, Flight
    @flights = AbstractFlight.scoped
    if params[:filter_model] && params[:filter_id]
      filter_by = (params[:filter_model] || "").singularize.camelcase
      unless %w(Airfield License Group Plane Person).include?(filter_by)
        render status: 404, text: ""
        return
      end
      @flights = filter_by.constantize.find(params[:filter_id]).flights
    end
    if params[:range]
      min, max = params[:range].split("_").map { |s| Date.parse(s) }.sort
      @flights = @flights.where("departure_date <= ? AND departure_date >= ?", max, min)
    else
      @flights = @flights.limit(40)
    end
    respond_to do |f|
      f.html { render_index }
      f.json { render json: @flights }
    end
  end

  def render_index
    @people = @flights.map(&:concerned_people).flatten.uniq.compact
    @airfields = @flights.map { |f| [f.from, f.to] }.flatten.uniq.compact
    @planes = Plane.all
    @wire_launchers = WireLauncher.all
    render :action => :index
  end

  def show
    flight = AbstractFlight.where(id: params[:id]).first
    if flight
      authorize! :read, flight
      respond_to do |f|
        f.html do
          @flights = [ flight, AbstractFlight.where("departure_date = ?", flight.departure_date).limit(40) ].flatten.uniq
          render_index
        end
        f.json { render json: flight }
      end
    else
      respond_to do |f|
        f.html { render file: "#{RAILS_ROOT}/public/404.html", status: 404 }
        f.json { render json: {}, status: 404 }
      end
    end
  end

  def update
    flight = AbstractFlight.find(params[:id])
    authorize! :update, flight
    flight.update_attributes!(params[:flight].slice(*flight.class.writable_attributes))
    render json: flight
  end

  def create
    authorize! :create, Flight
    flight_klass = (params[:flight][:type] ? params[:flight][:type].constantize : Flight)
    flight = flight_klass.create(params[:flight].slice(*flight_klass.writable_attributes))
    render json: flight
  end

  def destroy
    flight = Flight.find(params[:id])
    authorize! :destroy, flight
    flight.destroy
    render json: {}
  end
end
