class Flight < AbstractFlight   
  has_many :liabilities
  include FlightAddition

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
