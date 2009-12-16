require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PersonCostCategories/index.html.haml" do
  include PersonCostCategoriesHelper
  
  before do
    person_cost_category_98 = mock_model(PersonCostCategory)
    person_cost_category_98.should_receive(:name).and_return("MyString")
    person_cost_category_99 = mock_model(PersonCostCategory)
    person_cost_category_99.should_receive(:name).and_return("MyString")

    assigns[:person_cost_categories] = [person_cost_category_98, person_cost_category_99]
  end

  it "should render list of person_cost_categories" do
    render "/person_cost_categories/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end
