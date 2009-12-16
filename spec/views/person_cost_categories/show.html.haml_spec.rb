require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PersonCostCategories/show.html.haml" do
  include PersonCostCategoriesHelper
  
  before do
    @person_cost_category = mock_model(PersonCostCategory)
    @person_cost_category.stub!(:name).and_return("MyString")

    assigns[:person_cost_category] = @person_cost_category
  end

  it "should render attributes in <p>" do
    render "/person_cost_categories/show.html.haml"
    response.should have_text(/MyString/)
  end
end

