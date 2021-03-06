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
  
  def from_account_number
    from.try(:number)
  end

  def to_account_number
    to.try(:number)
  end

  def from_account_name
    from.try(:name)
  end

  def to_account_name
    to.try(:name)
  end

  def value_f
    value / 100.0
  end

  def text
    ''
  end
end
