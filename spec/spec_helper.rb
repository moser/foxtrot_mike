unless defined?(SetupSpec)
  #puts "server/spec/spec_helper"
  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  ENV["RAILS_ENV"] ||= 'test'
  require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
  require 'rspec/rails'
  require 'capybara/rspec'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  Dir["#{::Rails.root}/shared/spec/factories/**/*.rb"].each {|f| require f}
  Dir["#{::Rails.root}/spec/factories/**/*.rb"].each {|f| require f}

  require 'factory_girl/syntax/generate'
  
  class ActionView::TestCase::TestController
    def current_account
      return @current_account if defined?(@current_account)  
      @current_account = Account.generate!
      @current_account.account_roles.create :role => :admin 
      @current_account
    end

    def current_ability
      Class.new { 
        include CanCan::Ability
        def initialize(*a)
          can :manage, :all
        end
      }.new
    end
  end

  class ApplicationController
    def current_account
      return @current_account if defined?(@current_account)  
      @current_account = Account.generate!
      @current_account.account_roles.create :role => :admin 
      @current_account
    end

    def current_ability
      Class.new { 
        include CanCan::Ability
        def initialize(*a)
          can :manage, :all
        end
      }.new
    end
  end

  RSpec.configure do |config|
    config.use_transactional_fixtures = false
    config.use_instantiated_fixtures  = false
    config.mock_with "rspec"
    #
    # == Notes
    #
    # For more information take a look at Spec::Runner::Configuration and Spec::Runner
    config.include Haml::Helpers
    config.include ActionView::Helpers
    config.before(:each) do
      init_haml_helpers
    end
    config.include  Webrat::Matchers 
    config.include  Webrat::HaveTagMatcher
    config.before(:suite) do  
      DatabaseCleaner.strategy = :truncation  
    end  
      
    config.before(:each) do  
      DatabaseCleaner.start  
    end  
      
    config.after(:each) do  
      DatabaseCleaner.clean  
    end
  end
end
