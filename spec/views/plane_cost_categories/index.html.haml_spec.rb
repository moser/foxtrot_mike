require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PlaneCostCategories/index.html.haml" do
  include PlaneCostCategoriesHelper
  
  before do
    plane_cost_category_98 = mock_model(PlaneCostCategory)
    plane_cost_category_98.should_receive(:name).and_return("MyString")
    plane_cost_category_99 = mock_model(PlaneCostCategory)
    plane_cost_category_99.should_receive(:name).and_return("MyString")

    assigns[:plane_cost_categories] = [plane_cost_category_98, plane_cost_category_99]
  end

  it "should render list of plane_cost_categories" do
    render "/plane_cost_categories/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end
