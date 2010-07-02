require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PlaneCostCategory/edit.html.haml" do
  include PlaneCostCategoriesHelper
  
  before do
    assigns[:plane_cost_category] = @plane_cost_category = PlaneCostCategory.generate!
  end

  it "should render edit form" do
    render :template => "/plane_cost_categories/edit.html.haml"
    
#    response.should have_tag("form[action=#{plane_cost_category_path(@plane_cost_category)}][method=post]") do
#      with_tag('input#plane_cost_category_name[name=?]', "plane_cost_category[name]")
#    end
  end
end
