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
  
  def format_minutes(i)
    "#{i/60}:#{i%60 < 10 ? "0" : ""}#{i%60}" unless i.nil?
  end
  
  def format_currency(i)
    "€ #{i/100},#{i%100 < 10 ? "0" : ""}#{i%100}" unless i.nil? #TODO i18n/configurable
  end
  
  def format_time(d)
    d.strftime("%H:%M") unless d.nil?
  end
  
  def format_date(d)
    d.strftime("%d.%m.%Y") unless d.nil?
  end
  
  def format_datetime(d)
    d.strftime("%d.%m.%Y %H:%M:%S") unless d.nil?
  end
end
