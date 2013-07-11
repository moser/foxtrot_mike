# encoding: utf-8

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def navigation_li(data)
    content_tag(:li, navigation_data(data), :class => (current_path?(data[:path]) ? "active" : ""))
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

  def current_path?(path)
    current_path =~ /^#{path}/
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

  def format_currency(i, show_unit = true)
    "#{(i < 0) ? '-' : ''}#{(i.abs/100.0).to_i},#{i.abs%100 < 10 ? "0" : ""}#{i.abs%100}#{ show_unit ? ' €' : ''}" unless i.nil? #TODO i18n/configurable
  end

  def back_link(obj, options = {})
    link_to t('views.back'), obj, *[merge_class_into_options("back", options)] if can(:read, obj)
  end

  def show_link(obj, str = nil, options = {})
    unless str
      link_to t('views.show'), obj, *[merge_class_into_options("show", options)] if can(:read, obj)
    else
      link_to_unless cannot?(:read, obj), str, obj, *[options]
    end
  end

  def edit_link(obj, str = nil, options = {})
    options = merge_class_into_options("edit", options)
    unless str
      link_to t('views.edit'), polymorphic_path(obj, :action => :edit), *[options] if can(:update, obj)
    else
      link_to_unless cannot?(:update, obj), str, polymorphic_path(obj, :action => :edit), *[options]
    end
  end

  def new_link(klass, str = nil, options = {})
    options = merge_class_into_options("new", options)
    unless str
      link_to t('views.new'), polymorphic_path(klass, :action => :new), *[options] if can(:create, klass)
    else
      link_to_unless cannot?(:create, klass), str, polymorphic_path(klass, :action => :new), *[options]
    end
  end

  def add_link(klass, options = {})
    link_to t('views.add'), polymorphic_path(klass, :action => :new), *[merge_class_into_options("add", options)] if can(:create, [klass].flatten.last)
  end

  def destroy_link(obj, options = {})
    #link_to t('views.destroy'), polymorphic_path(obj, :action => :destroy), *[options] if can(:destroy, obj)
  end

  def destroy_confirmation_link(obj, options = {})
    link_to t('views.destroy'), polymorphic_path([obj, :destroy_confirmation], :action => :new), *[merge_class_into_options("facebox", options)] if can(:destroy, obj)
  end

  def can(what, obj)
    obj = obj[0] if Array === obj
    can?(what, obj)
  end

  def scoped_flights_path(scope, params = nil)
    unless params
      "#{polymorphic_path(scope)}/flights"
    else
      polymorphic_path(scope, params).gsub("?", "/flights?")
    end
  end

private
  def merge_class_into_options(cls, options)
    if options[:class]
      options[:class] += " #{cls}"
      options
    else
      options.merge({ :class => cls })
    end
  end
end
