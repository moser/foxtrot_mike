class GroupCost
  attr_reader :group, :start_date, :end_date

  def initialize(group, start_date, end_date)
    @group, @start_date, @end_date = [ group, start_date, end_date ]
  end

  # returns
  # { person => {
  #        some_plane => { count: 1, cost: 233 },
  #        some_wire_launcher => { count: 2, cost 100 }
  #        },...
  # }
  def people_with_sorted_cost
    unless @people_with_sorted_cost
      res = group.people.map do |person|
        [ person, sorted_cost_for(person) ]   
      end
      @people_with_sorted_cost = Hash[res]
    end
    @people_with_sorted_cost
  end

  def sum_for_person(person)
    liabilities_for(person).map(&:value).sum
  end

  def sum
    liabilities.map(&:value).sum
  end

  def settle(text, account)
    accounting_session = AccountingSession.create(name: text, voucher_number: 0, accounting_date: Date.today, without_flights: true)
    group.people.each do |person|
      accounting_session.manual_accounting_entries.create(from: account, to: person.financial_account, text: text, value: sum_for_person(person))
    end
    accounting_session
  end

private
  def sorted_cost_for(person)
    foo = liabilities_for(person).map do |liability|
      cost_for(liability)
    end
    foo = foo.select { |h| !h.keys.empty? }

    x = foo.map(&:keys).flatten.uniq
    r = {}
    x.each do |k|
      r[k] = foo.map { |h| h[k] }.compact.reduce do |a, b|
        { cost: a[:cost] + b[:cost], count: a[:count] + b[:count] }
      end
    end
    r
  end

  def flights
    @flights ||= group.flights.where('departure_date BETWEEN ? AND ?', start_date, end_date)
  end

  def liabilities
    @liabilities ||= flights.map(&:liabilities_with_default).flatten
  end

  def liabilities_for(person)
    liabilities.select do |liability|
      liability.person.id == person.id
    end
  end

  def cost_for(liability)
    cost = {}
    flight = liability.flight
    proportion = flight.proportion_for(liability)
    if flight.cost.free_sum > 0
      cost[flight.plane] = cost_for_item(flight, proportion)
    end
    if flight.launch.is_a?(WireLaunch)
      cost[flight.launch.wire_launcher] = cost_for_item(flight.launch, proportion)
    elsif flight.launch.is_a?(TowFlight)
      cost[flight.launch.plane] = cost_for_item(flight.launch, proportion)
    end
    cost
  end

  def cost_for_item(item, proportion)
    if item.is_a?(AbstractFlight)
      count = item.duration
    elsif item.is_a?(WireLaunch)
      count = 1
    end
    { count: count, cost: (item.cost.free_sum.to_f * proportion).round }
  end
end
