module TimelineStuff
  SCOPES = %w(day week month year)
  VARS = %w(scope zoom_in zoom_out base groups first_group next_base prev_base from to flights_for_timeline counts)
  GROUP_COUNT = 15

  def setup_scope(current_scope)
    @scope = current_scope || "day"
    @zoom_out = SCOPES[SCOPES.find_index(@scope) + 1]
    @zoom_in = ((i = SCOPES.find_index(@scope) - 1) >= 0 ? SCOPES[i] : nil)
  end

  def setup_groups(current_base)
    @base = (current_base ? Date.parse(current_base) : Date.today).send("end_of_#{@scope}").to_date
    @groups = [@base]
    (GROUP_COUNT - 1).times do 
      @groups << @groups.min.send("prev_#{@scope}").send("end_of_#{@scope}").to_date
    end
    @groups.sort!
    @first_group = @groups.min.send("prev_#{@scope}").send("end_of_#{@scope}").to_date
    @next_base = @groups.max.send("next_#{@scope}").send("end_of_#{@scope}").to_date
    @prev_base = @groups[-2]
  end

  def sanitize_range(from, to)
    from, to = [ to, from ] if from > to

    from = @first_group if from < @first_group
    to = @groups.last if to > @groups.last

    if from == to
      unless from == @first_group
        from = @groups[@groups.find_index(to) - 1]
      else
        to = @groups[0]
      end
    end

    [from, to]
  end

  def setup_range(current_from, current_to)
    @from = current_from ? Date.parse(current_from).send("end_of_#{@scope}").to_date : @groups[-2]
    @to = current_to ? Date.parse(current_to).send("end_of_#{@scope}").to_date : @groups.last
    
    if @to > @groups.last
      setup_groups(@to.to_s)
      @from = @first_group if @from < @first_group
    end
    
    if @from < @first_group
      setup_groups((@from + (GROUP_COUNT).send(@scope)).to_s)
    end

    @from, @to = sanitize_range(@from, @to)
  end

  def setup_vars(flight_relation)
    setup_scope(params[:scope])
    setup_groups(params[:base])
    setup_range(params[:from], params[:to])
    
    @flights_for_timeline = flight_relation.
                where(Flight.arel_table[:departure].gt(@groups.first.send("end_of_#{@scope}")).
                      and(Flight.arel_table[:departure].lteq(@groups.last.end_of_day)))

    @counts = Hash[@groups.map { |d| [d, 0] } ]
    @flights_for_timeline.each do |f|
      @counts[f.departure_date.send("end_of_#{@scope}").to_date] += 1
    end
  end

  def timeline_locals(url_obj)
    l = { :url_obj => url_obj }
    VARS.each {|v| l[v.to_sym] = instance_values[v] }
    l
  end
end
