require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'authlogic'

module Server
  class Application < Rails::Application
    config.autoload_paths += %W( #{config.root}/shared/app/models #{config.root}/shared/app/libr #{config.root}/lib )
    config.i18n.default_locale = :de
    
    config.assets.enabled = true

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, :fixture => true, :views => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    config.encoding = "utf-8"

    config.filter_parameters += [:password]
  end
end
