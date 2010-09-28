require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/flights/index.html.haml" do
  helper :application, :flights

  before(:each) do
    assigns[:flights] = @flights = Flight.paginate(:per_page => 5, :page => 1)
  end

  it "renders a list of flights" do
    render    
  end
end
