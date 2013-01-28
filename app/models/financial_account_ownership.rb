class FinancialAccountOwnership < ActiveRecord::Base
  belongs_to :financial_account
  accepts_nested_attributes_for :financial_account
  belongs_to :owner, :polymorphic => true

  validates_presence_of :financial_account, :owner


  def self.valid_at(time)
    all.select { |o| o.valid_at?(time) }
  end

  def valid_from=(date)
    date = date.to_date if date.respond_to?(:to_date)
    write_attribute(:valid_from, date)
  end

  def valid_at?(date)
    date = date.to_date if date.respond_to?(:to_date)
    (!valid_from || date >= valid_from) && (!valid_to || valid_to >= date)
  end

  def valid_to
    unless owner.new_record?
      succ = FinancialAccountOwnership.where(:owner_id => owner.id, :owner_type => owner.class.to_s).where("id != ?", self.id).where("valid_from >= ?", (valid_from || 1000.years.ago)).order("valid_from ASC, updated_at DESC").reject { |o| o.valid_from == self.valid_from && o.updated_at < self.updated_at }.first
      succ.valid_from if succ
    end
  end

  def plane
    owner
  end

  def person
    owner
  end

  def wire_launcher
    owner
  end

  def plane=(o)
    self.owner = o
  end

  def person=(o)
    self.owner = o
  end

  def wire_launcher=(o)
    self.owner = o
  end
end
