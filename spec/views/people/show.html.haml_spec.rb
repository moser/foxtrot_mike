require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.haml" do
  include PeopleHelper
  
  before do
    assigns[:person] = @person = Person.generate!
  end

  it "should render" do
    render
  end
end

