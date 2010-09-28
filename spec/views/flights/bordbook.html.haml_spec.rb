require File.dirname(__FILE__) + '/../../spec_helper'

describe "/flights/bordbook.html.haml" do
  include FlightsHelper
  include TimelineStuff
  
  before do
    assigns[:flights] = @flights = [
      Flight.generate!,
      Flight.generate!
    ]
    setup_scope(nil)
    setup_groups(nil)
    setup_range(nil, nil)
    @counts = {Date.today => 1}
    assigns[:timeline_locals] = @timeline_locals = timeline_locals(@url_obj = Plane.generate!)
    assigns[:calculated_flights] = @calculated_flights = [{ :group_id => "d", :flights => [Flight.generate!]}]
  end

  it "should render" do
    render
  end
end
