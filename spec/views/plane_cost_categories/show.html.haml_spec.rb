require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PlaneCostCategories/show.html.haml" do
  include PlaneCostCategoriesHelper
  
  before do
    @plane_cost_category = mock_model(PlaneCostCategory)
    @plane_cost_category.stub!(:name).and_return("MyString")

    assigns[:plane_cost_category] = @plane_cost_category
  end

  it "should render attributes in <p>" do
    render "/plane_cost_categories/show.html.haml"
    response.should have_text(/MyString/)
  end
end

