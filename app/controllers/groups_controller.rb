class GroupsController < ResourceController
  #prepend_before_filter :login_required
  def cost_overview
    model_by_id
    @flights = @group.flights
    if @from = get_date(:from)
      @flights = @flights.where('departure_date >= ?', @from)
    end
    if @to = get_date(:to)
      @flights = @flights.where('departure_date <= ?', @to)
    end
    @from ||= @flights.last.try(:departure_date) || Date.today
    @to ||= @flights.first.try(:departure_date) || Date.today
  end

private
  def get_date(key)
    begin
      Date.new(*params[:report].select { |k,v| k.include?(key.to_s) }.sort_by { |a| a.first }.map(&:last).map(&:to_i))
    rescue
    end
  end
end
