class Flight < AbstractFlight   
  has_many :liabilities
  belongs_to :cost_hint
  
  def accounting_entries
    launch_account = launch.nil? ? nil : launch.financial_account
    plane_account = plane.financial_account
    launch_sum = launch_cost.free_sum if launch_cost
    flight_sum = cost.free_sum if cost
    b = liabilities_with_default.map do |l|
      e = []
      unless launch_cost.nil? || launch_account.nil?
        e << AccountingEntry.new(:from => l.person.financial_account, :to => launch_account, 
                                    :value => (proportion_for(l) * launch_sum).round, :item => launch)
      end 
      unless cost.nil?
        e << AccountingEntry.new(:from => l.person.financial_account, :to => plane_account, 
                                   :value => (proportion_for(l) * flight_sum).round, :item => self)
      end
    end
    b << cost.bound_items.map { |i| AccountingEntry.new(:from => i.financial_account, :to => plane_account,
                                          :value => i.value, :item => self) } if cost
    b << launch_cost.bound_items.map { |i| AccountingEntry.new(:from => i.financial_account, :to => launch_account,
                                          :value => i.value, :item => launch) } if launch_cost
    b.flatten
  end

  def liabilities_with_default
    liabilities.count == 0 ? [ DefaultLiability.new(self) ] : liabilities
  end


  def proportion_sum
    liabilities_with_default.map { |l| l.proportion }.sum
  end
  
  def value_for(liability)
    (proportion_for(liability) * cost.sum.to_f).round
  end
  
  def proportion_for(liability)
    liability.proportion.to_f / proportion_sum.to_f
  end
  
  def liabilities_attributes=(attrs)
    unless attrs.nil?
      attrs.each do |h|
        obj = h.delete(:type).constantize.new(h)
        obj.id = h[:id]
        obj.save
        liabilities << obj
      end
    end
  end

  def liabilities_attributes
    liabilities.map { |l| l.attributes }
  end
  
  def shared_attributes
    a = super
    a[:liabilities_attributes] = liabilities_attributes
    a
  end
  
  def initialize(*args)
    super(*args)
    if new_record?
      self.departure ||= Date.today
    end
  end
end
