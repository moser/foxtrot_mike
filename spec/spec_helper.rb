unless defined?(SetupSpec)
  #puts "server/spec/spec_helper"
  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  ENV["RAILS_ENV"] ||= 'test'
  require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
  require 'rspec/rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  require 'factory_girl/syntax/generate'

  F = FactoryGirl

  class ActionView::TestCase::TestController
    helper_method :current_account
    def current_account
      return @current_account if defined?(@current_account)
      @current_account = F.create(:account)
      @current_account
    end

    def current_ability
      @current_ability ||= Class.new {
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
      @current_account = F.create(:account)
      @current_account
    end

    def current_ability
      @current_ability ||= Class.new {
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
