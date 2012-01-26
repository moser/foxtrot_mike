class AggregatedEntry
  attr_accessor :from, :to, :entries

  def initialize(from, to, entries)
    @from = from
    @to = to
    @entries = entries
  end

  def value
    entries.map { |e| e.value }.sum
  end

  def manual?
    false
  end
end
