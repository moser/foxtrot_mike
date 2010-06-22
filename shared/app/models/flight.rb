class Flight < AbstractFlight   
  has_many :liabilities
  include FlightAddition
  
  def proportion_sum
    liabilities.map { |l| l.proportion }.sum
  end
  
  def value_for(liability)
    (liability.proportion.to_f * cost.to_i.to_f / proportion_sum.to_f).to_i
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
  
  def shared_attributes
    a = super
    a[:liabilities_attributes] = liabilities.map { |l| l.attributes }
    a
  end
  
protected  
  def after_initialize
    if new_record?
      self.departure ||= Date.today
      self.duration ||= 0
    end
  end
end
