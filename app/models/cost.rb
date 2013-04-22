class Cost
  #funny way to make sure that all classes required for deserializing instances of this class:
  FOO = [ FlightCostRule, WireLaunchCostRule, CostItem, FlightCostItem ]
  attr_accessor :items, :cost_rule

  def initialize(cost_rule = nil, items = [])
    @cost_rule = cost_rule
    @items = items
  end

  def sum
    items.map { |i| i.value }.sum
  end

  def free_sum
    items.map { |i| i.free? ? i.value : 0 }.sum
  end

  def bound_items
    items.select { |i| !i.free? }
  end

  def as_json
    super.merge({ sum: sum, free_sum: free_sum, empty: empty? })
  end

  def empty?
    @cost_rule.nil? && @items.empty?
  end
end
