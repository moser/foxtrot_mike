class ViewGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :controller, :type => :string
  argument :name, :type => :string

  def generate_view
    template "view.html.haml.erb", "app/views/#{controller.underscore}/#{name.underscore}.html.haml" 
    template "view.html.haml_spec.rb.erb", "spec/views/#{controller.underscore}/#{name.underscore}.html.haml_spec.rb" 
  end  

end
