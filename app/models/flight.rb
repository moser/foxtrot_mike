class Flight < AbstractFlight   
  has_many :liabilities
  
  def accounting_entries
    launch_account = launch.nil? ? nil : launch.financial_account
    plane_account = plane.financial_account
    launch_cost = launch.cost.value
    flight_cost = cost.value
    b = liabilities_with_default.map do |l|
      e = []
      unless launch_account.nil?
        e = [ AccountingEntry.new(:from => l.person.financial_account, :to => launch_account, 
                                    :value => (proportion_for(l) * launch_cost).round, :item => launch) ]
      end 
      e << AccountingEntry.new(:from => l.person.financial_account, :to => plane_account, 
                                 :value => (proportion_for(l) * flight_cost).round, :item => self)
    end
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
