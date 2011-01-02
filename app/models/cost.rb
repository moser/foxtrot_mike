class Cost
  attr_accessor :items, :cost_rule

  def initialize(cost_rule, items = [])
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
end
