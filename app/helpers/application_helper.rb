# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_items
    { "flights" => flights_path,
      "planes" => planes_path,
      "accounts" => accounts_path,
      "airfields" => airfields_path,
      "plane_cost_categories" => plane_cost_categories_path,
      "person_cost_categories" => person_cost_categories_path,
      "people" => people_path,
      "plane_cost_rules" => plane_cost_rules_path,
      "wire_launchers" => wire_launchers_path }
  end
  
  def labeled_text_field(form, method, options = {})
    form.label(method) + "\n" + form.text_field(method, options) 
  end
  
  def format_minutes(i)
    unless i.nil? || i < 0
      "#{i/60}:#{i%60 < 10 ? "0" : ""}#{i%60}"
    else
      "-"
    end
  end
  
  def format_currency(i)
    "€ #{i/100},#{i%100 < 10 ? "0" : ""}#{i%100}" unless i.nil? #TODO i18n/configurable
  end

  class CustomLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer 
    

    protected
    def page_number(page)
      unless page == current_page
        link(page, page, :rel => rel_value(page), :"data-page" => page, :class => "page")
      else
        tag(:em, page)
      end
    end
    
    def previous_or_next_page(page, text, classname)
      if page
        link(text, page, :class => classname + ' page', :"data-page" => page)
      else
        tag(:span, text, :class => classname + ' page disabled', :"data-page" => page)
      end
    end

  end
end
