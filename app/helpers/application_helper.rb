# encoding: utf-8

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_items
    Tree.new do |t|
      t.children << Leaf.new({:name => "dashboard", :path => dashboard_path}) if can?(:read, :dashboards)
      t.children << Leaf.new({:name => "flights", :path => flights_path})  if can?(:read, Flight)
      if can?(:read, Plane) || can?(:read, WireLauncher) || can?(:read, Airfield) || can?(:read, Person)
        t.children << Tree.new({ :name => "master_data" }) do |m|
          m.children << Leaf.new({:name => "planes", :path => planes_path})  if can?(:read, Plane)
          m.children << Leaf.new({:name => "wire_launchers", :path => wire_launchers_path})  if can?(:read, WireLauncher)
          m.children << Leaf.new({:name => "airfields", :path => airfields_path}) if can?(:read, Airfield)
          m.children << Leaf.new({:name => "financial_accounts", :path => financial_accounts_path}) if can?(:read, FinancialAccount)
          if can?(:read, Person)
            m.children << Tree.new({:name => "people", :path => people_path}) do |k|
              k.children << Leaf.new({:name => "licenses", :path => licenses_path}) if can?(:read, License)
              k.children << Leaf.new({:name => "accounts", :path => accounts_path}) if can?(:read, Account)
            end
          end
        end
      end
      if can?(:read, Group) || can?(:read, LegalPlaneClass) || can?(:read, PersonCostCategory) || can?(:read, PlaneCostCategory) || can?(:read, WireLauncherCostCategory)
        t.children << Tree.new({ :name => "categories" }) do |k|
          k.children << Leaf.new({:name => "groups", :path => groups_path}) if can?(:read, Group)
          k.children << Leaf.new({:name => "legal_plane_classes", :path => legal_plane_classes_path}) if can?(:read, LegalPlaneClass)
          k.children << Leaf.new({:name => "cost_hints", :path => cost_hints_path}) if can?(:read, CostHint)
          if can?(:read, PersonCostCategory) || can?(:read, PlabeCostCategory) || can?(:read, WireLauncherCostCategory)
            k.children << Tree.new({ :name => "cost_categories" }) do |j|
              j.children << Leaf.new({:name => "person_cost_categories", :path => person_cost_categories_path}) if can?(:read, PersonCostCategory)
              j.children << Leaf.new({:name => "plane_cost_categories", :path => plane_cost_categories_path}) if can?(:read, PlaneCostCategory)
              j.children << Leaf.new({:name => "wire_launcher_cost_categories", :path => wire_launcher_cost_categories_path}) if can?(:read, WireLauncherCostCategory)
            end
          end
        end
      end
      if can?(:read, :cost_rules) || can?(:read, AccountingSession)
        t.children << Tree.new({ :name => "accounting" }) do |k|
          k.children << Leaf.new({:name => "cost_rules", :path => cost_rules_path}) if can?(:read, :cost_rules)
          k.children << Leaf.new({:name => "accounting_sessions", :path => accounting_sessions_path}) if can?(:read, AccountingSession)
        end
      end
      t.children << Leaf.new({:name => "logout", :path => "/logout", :class => "logout"})
    end
  end

  def navigation(tree = nil)
    if tree.nil?
      navigation(navigation_items)
    else
      r = "#{navigation_data(tree.data)}\n"
      x = tree.children.map { |t| content_tag(:li, navigation(t), :class => (t.current?(current_path) ? "current " : "") + (t.data[:class] || "")) }
      if x.size > 0
        r << content_tag(:ul, x.join("\n").html_safe)
      end
      r.html_safe
    end 
  end

  def navigation_data(data)
    if data[:name]
      if data[:name] == "logout"
        link_to t("#{data[:name]}.index.title", :name => current_account.person.name), data[:path] || '#'
      else
        link_to t("#{data[:name]}.index.title"), data[:path] || '#'
      end
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

  def back_link(obj, options = {})
    link_to t('views.back'), obj, *[options] if can?(:read, obj)
  end

  def show_link(obj, str = nil, options = {})
    unless str
      link_to t('views.show'), obj, *[options] if can?(:read, obj)
    else
      link_to_unless cannot?(:read, obj), str, obj, *[options]
    end
  end

  def edit_link(obj, str = nil, options = {})
    unless str
      link_to t('views.edit'), polymorphic_path(obj, :action => :edit), *[options] if can?(:update, obj)
    else
      link_to_unless cannot?(:update, obj), str, polymorphic_path(obj, :action => :edit), *[options]
    end
  end

  def new_link(klass, str = nil, options = {})
    unless str
      link_to t('views.new'), polymorphic_path(klass, :action => :new), *[options] if can?(:create, klass)
    else
      link_to_unless cannot?(:create, klass), str, polymorphic_path(klass, :action => :new), *[options]
    end
  end

  def add_link(klass, options = {})
    link_to t('views.add'), polymorphic_path(klass, :action => :new), *[options] if can?(:create, [klass].flatten.last)
  end

  def destroy_link(obj, options = {})
    #link_to t('views.destroy'), polymorphic_path(obj, :action => :destroy), *[options] if can?(:destroy, obj)
  end
end
