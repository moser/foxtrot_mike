require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.dirname(__FILE__) + "/../config/environment" 
  require 'rspec/rails'

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

  require 'database_cleaner'
  RSpec.configure do |config|
    config.use_transactional_fixtures = false
    config.use_instantiated_fixtures  = false
    config.mock_with "rspec"

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

Spork.each_run do
  puts "creating in mem DB"
  silence_stream(STDOUT) do
    silence_stream(STDERR) do
      load "#{Rails.root}/db/schema.rb"
    end
  end
end
