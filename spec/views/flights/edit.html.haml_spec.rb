require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/edit.html.haml" do
  include FlightsHelper

  before(:each) do
    assigns[:flight] = @flight = stub_model(Flight,
      :new_record? => false,
      :duration => 1
    )
  end

  it "renders the edit flight form" do
    render

    response.should have_tag("form[action=#{flight_path(@flight)}][method=post]") do
      with_tag('input#flight_duration[name=?]', "flight[duration]")
    end
  end
end
