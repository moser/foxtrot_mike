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

  def visible_name
    if person
      person.name
    else
      login
    end
  end
end
