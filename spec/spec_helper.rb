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
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # == Fixtures
    #
    # You can declare fixtures for each example_group like this:
    #   describe "...." do
    #     fixtures :table_a, :table_b
    #
    # Alternatively, if you prefer to declare them only once, you can
    # do so right here. Just uncomment the next line and replace the fixture
    # names with your fixtures.
    #
    # config.global_fixtures = :table_a, :table_b
    #
    # If you declare global fixtures, be aware that they will be declared
    # for all of your examples, even those that don't use them.
    #
    # You can also declare which fixtures to use (for example fixtures for test/fixtures):
    #
    # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
    #
    # == Mock Framework
    #
    # RSpec uses it's own mocking framework by default. If you prefer to
    # use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    config.mock_with :rspec
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
  end
end
