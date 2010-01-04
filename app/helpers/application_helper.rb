# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_items
    { "flights" => flights_path,
      "planes" => planes_path,
      "accounts" => accounts_path,
      "airfields" => airfields_path,
      "plane_cost_category" => plane_cost_categories_path,
      "person_cost_category" => person_cost_categories_path,
      "people" => people_path }
  end
  
  def labeled_text_field(form, method, options = {})
    form.label(method) + "\n" + form.text_field(method, options) 
  end
end
