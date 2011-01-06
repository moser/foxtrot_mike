require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/index.html.haml" do
  helper :application, :flights

  before(:each) do
    assigns[:current_day] = @current_day = AbstractFlight.latest_departure
    assigns[:dates] = @dates = AbstractFlight.group("date(departure)").order("date(departure) DESC").count
    assigns[:flights] = @flights = AbstractFlight.include_all.where("departure < ? and departure > ?", @current_day + 1.day, @current_day)
  end

  it "renders a list of flights" do
    render    
  end
end
