# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_items
    @navigation_items ||= Tree.new do |t|
      t.children << Leaf.new({:name => "dashboard", :path => dashboard_path})
      t.children << Leaf.new({:name => "flights", :path => flights_path})
      t.children << Tree.new({:name => "people", :path => people_path}) do |k|
        k.children << Leaf.new({:name => "licenses", :path => licenses_path})
      end
      t.children << Tree.new({:name => "machines"}) do |k|
        k.children << Leaf.new({:name => "planes", :path => planes_path})
        k.children << Leaf.new({:name => "wire_launchers", :path => wire_launchers_path})
      end
      t.children << Leaf.new({:name => "airfields", :path => airfields_path})
      t.children << Tree.new({ :name => "categories" }) do |k|
        k.children << Leaf.new({:name => "groups", :path => groups_path})
        k.children << Leaf.new({:name => "legal_plane_classes", :path => legal_plane_classes_path})
        k.children << Tree.new({ :name => "cost_categories" }) do |j|
          j.children << Leaf.new({:name => "person_cost_categories", :path => person_cost_categories_path})
          j.children << Leaf.new({:name => "plane_cost_categories", :path => plane_cost_categories_path})
          j.children << Leaf.new({:name => "wire_launcher_cost_categories", :path => wire_launcher_cost_categories_path})
        end
      end
      t.children << Tree.new({ :name => "cost" }) do |k|
        k.children << Leaf.new({:name => "plane_cost_rules", :path => plane_cost_rules_path})
        k.children << Leaf.new({:name => "wire_launcher_cost_rules", :path => wire_launcher_cost_rules_path})
      end
      t.children << Leaf.new({:name => "accounts", :path => accounts_path})
    end
  end

  def navigation(tree = nil)
    if tree.nil?
      navigation(navigation_items)
    else
      r = "#{navigation_data(tree.data)}\n"
      x = tree.children.map { |t| content_tag(:li, navigation(t), :class => t.current?(current_path) ? "current" : "") }
      if x.size > 0
        r << content_tag(:ul, x.join("\n").html_safe)
      end
      r.html_safe
    end 
  end

  def navigation_data(data)
    if data
      link_to t("#{data[:name]}.index.title"), data[:path] || '#'
      #link_to data[:name], data[:path] || '#'
    end
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
