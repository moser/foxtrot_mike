require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/edit.html.haml" do
  helper :application, :flights

  before(:each) do
    assigns[:flight] = @flight = Flight.generate!
  end

  it "renders the edit flight form" do
    render

#    response.should have_tag("form[action=#{flight_path(@flight)}][method=post]") do
#      with_tag('input#flight_duration[name=?]', "flight[duration]")
#    end
  end
end
