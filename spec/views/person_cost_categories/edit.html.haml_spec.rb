require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PersonCostCategory/edit.html.haml" do
  include PersonCostCategoriesHelper
  
  before do
    assigns[:person_cost_category] = @person_cost_category = PersonCostCategory.generate!
  end

  it "should render edit form" do
    render "/person_cost_categories/edit.html.haml"
    
    response.should have_tag("form[action=#{person_cost_category_path(@person_cost_category)}][method=post]") do
      with_tag('input#person_cost_category_name[name=?]', "person_cost_category[name]")
    end
  end
end
