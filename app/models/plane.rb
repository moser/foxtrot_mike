class Plane < ActiveRecord::Base
  include UuidHelper
  include Membership
  include Current
  include AccountingEntryInvalidation

  LAUNCH_METHODS = [ "self_launch", "tow_launch", "wire_launch" ]

  after_initialize :init

  has_many :flights, :class_name => "AbstractFlight", :include => AbstractFlight::IncludeAll 
  has_many :plane_cost_category_memberships, :order => "valid_from ASC"
  has_many :financial_account_ownerships, :as => :owner, :after_add => :association_changed, :after_remove => :association_changed
  has_one_current :financial_account_ownership
  belongs_to :legal_plane_class
  belongs_to :group
  membership :plane_cost_category_memberships

  belongs_to :duplicate_of, class_name: 'Plane'
  has_many :duplicates, class_name: 'Plane', foreign_key: 'duplicate_of_id'

  validates_presence_of :registration, :make, :legal_plane_class, :group, :default_launch_method
  validates_inclusion_of :default_launch_method, :in => LAUNCH_METHODS

  default_scope order("registration asc")

  def self.mergable(plane)
    self.where(duplicate_of_id: nil).where("id <> ?", plane.id).all
  end

  def financial_account
    current_financial_account_ownership && current_financial_account_ownership.financial_account
  end

  def financial_account=(fa)
    if new_record?
      financial_account_ownerships << FinancialAccountOwnership.create(:financial_account => fa, :owner => self)
    end
  end

  def financial_account_at(date)
    financial_account_ownership_at(date) && financial_account_ownership_at(date).financial_account
  end

  def financial_account_id
    financial_account && financial_account.id
  end

  def financial_account_id=(fa)
    begin
      self.financial_account = FinancialAccount.find(fa)
    rescue ActiveRecord::RecordNotFound
    end
  end

  def to_s
    registration || ""
  end

  def engine_duration_possible?
    has_engine && can_fly_without_engine
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def info
    "#{make}, #{group.name}"
  end

  def find_concerned_accounting_entry_owners(&blk)
    blk ||= lambda { |r| r }
    blk.call(flights)
  end

  def as_json(options)
    a = [ :id, 
      :registration, 
      :make, 
      :competition_sign,
      :group_id,
      :default_launch_method,
      :has_engine,
      :default_engine_duration_to_duration,
      :can_fly_without_engine,
      :can_tow, :can_be_towed,
      :can_be_wire_launched,
      :deleted,
      :disabled,
      :legal_plane_class_id,
      :selflaunching,
      :seat_count ]
    self.attributes.reject { |k,v| !a.include?(k.to_sym) }.merge({ :group_name => group.name })
  end

  def merge_info
    "#{registration} #{make} (#{flights.count} #{AbstractFlight.l(:plural)})"
  end

  def merge_to(other_plane)
    flights.each do |f|
      f.update_attribute :plane, other_plane
    end
    update_attributes disabled: true, deleted: true, duplicate_of_id: other_plane.id
  end

private
  def association_changed(obj = nil)
    invalidate_concerned_accounting_entries
  end

  def init
    self.default_launch_method ||= "self_launch"
    self.competition_sign ||= ""
    self.seat_count = 1 if seat_count.nil?
    self.has_engine = false if has_engine.nil?
    self.can_tow = false if can_tow.nil?
    self.selflaunching = false if selflaunching.nil?
    self.can_be_towed = false if can_be_towed.nil?
    self.can_be_wire_launched = false if can_be_wire_launched.nil?
    self.can_fly_without_engine = false if can_fly_without_engine.nil?
    self.default_engine_duration_to_duration = false if default_engine_duration_to_duration.nil?
  end

  def self.import(hashes)
    ActiveRecord::Base.transaction do
      hashes.each do |hash|
        begin
          import_group(hash)
          import_legal_plane_class(hash)
          Plane.create!(hash)
        rescue => e
          raise "#{e.message} - #{hash.inspect}"
        end
      end
    end
  end

private
  def self.import_group(hash)
    group_name = hash.delete(:group)
    if group_name
      hash[:group_id] = Group.where(name: group_name).first_or_create.id
    end
  end

  def self.import_legal_plane_class(hash)
    legal_plane_class_name = hash.delete(:legal_plane_class)
    if legal_plane_class_name
      hash[:legal_plane_class_id] = LegalPlaneClass.where(name: legal_plane_class_name).first_or_create.id
    end
  end
end
