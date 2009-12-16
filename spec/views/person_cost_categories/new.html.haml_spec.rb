require File.dirname(__FILE__) + '/../../spec_helper'

describe "/PersonCostCategories/new.html.haml" do
  include PersonCostCategoriesHelper
  
  before do
    @person_cost_category = mock_model(PersonCostCategory)
    @person_cost_category.stub!(:new_record?).and_return(true)
    @person_cost_category.stub!(:name).and_return("MyString")
    assigns[:person_cost_category] = @person_cost_category
  end

  it "should render new form" do
    render "/person_cost_categories/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", person_cost_categories_path) do
      with_tag("input#person_cost_category_name[name=?]", "person_cost_category[name]")
    end
  end
end
