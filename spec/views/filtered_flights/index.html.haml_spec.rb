require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/filtered_flights/index.html.haml" do
  helper :application, :filtered_flights
  
  before(:each) do
    @from = @to = Date.today
    @flights = [ Flight.generate!(:duration => 5), Flight.generate!(:duration => 10) ]
  end

  it "renders a list of flights" do
    render
    response.should have_tag("span.number", :content => "0:15")
  end
  
  it "renders a list for each person" do
    @flights = @flights.group_by &:grouping_people
    @group_by = "people"
    render
    response.should have_tag("span.number", :content => "0:05")
    response.should have_tag("span.number", :content => "0:10")
  end
end
