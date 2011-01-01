class Account < ActiveRecord::Base
  acts_as_authentic
  belongs_to :person
  has_many :account_roles

  #validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  #validates_uniqueness_of   :login

  def roles
    @roles ||= account_roles.map { |a| a.role.to_sym }
  end

  def role?(r)
    roles.include?(r.to_sym)
  end
end
