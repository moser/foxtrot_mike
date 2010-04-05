require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PlaneCostCategories/new.html.haml" do
  include PlaneCostCategoriesHelper
  
  before do
    assigns[:plane_cost_category] = @plane_cost_category = PlaneCostCategory.new
  end

  it "should render new form" do
    render "/plane_cost_categories/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", plane_cost_categories_path) do
      with_tag("input#plane_cost_category_name[name=?]", "plane_cost_category[name]")
    end
  end
end
