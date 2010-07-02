require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/index.html.haml" do
  include PeopleHelper
  
  before do
    person_98 = mock_model(Person)
    person_98.should_receive(:firstname).and_return("MyString")
    person_98.should_receive(:lastname).and_return("MyString")
    person_98.should_receive(:email).and_return("MyString")
    person_98.should_receive(:birthdate).and_return(Time.now)
    person_99 = mock_model(Person)
    person_99.should_receive(:firstname).and_return("MyString")
    person_99.should_receive(:lastname).and_return("MyString")
    person_99.should_receive(:email).and_return("MyString")
    person_99.should_receive(:birthdate).and_return(Time.now)

    assigns[:people] = @people = [person_98, person_99]
  end

  it "should render list of people" do
    render :template => "people/index.html.haml"
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
  end
end
