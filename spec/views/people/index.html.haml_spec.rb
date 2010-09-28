require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/index.html.haml" do
  include PeopleHelper
  
  before do
    assigns[:people] = @people = [Person.generate!, Person.generate!]
  end

  it "should render list of people" do
    render
  end
end
