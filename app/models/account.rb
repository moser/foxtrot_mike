class Account < ActiveRecord::Base
  acts_as_authentic
  belongs_to :person

  #validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  #validates_uniqueness_of   :login
end
