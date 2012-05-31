if Rails.env == "test" &&
   !defined?(SCHEMA_LOADED)
   ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter &&
   Rails.configuration.database_configuration['test']['database'] == ':memory:'
  puts "creating sqlite in memory database"
  silence_stream(STDOUT) do
    load "#{Rails.root}/db/schema.rb"
  end
  SCHEMA_LOADED = true
end

class Account < ActiveRecord::Base
  acts_as_authentic
  belongs_to :person

  #validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  #validates_uniqueness_of   :login

  def role?(r)
    self.send(r) if Account.roles.include?(r.to_sym)
  end

  def self.roles
    [ :admin, :license_official, :treasurer, :controller, :reader ]
  end
end
