class CostItem
  attr_accessor :cost_item, :value, :financial_account
  
  def initialize(cost_item, value, financial_account = nil)
    @cost_item = cost_item
    @value = value
    @financial_account = financial_account
  end 

  def free?
    financial_account == nil
  end
end
