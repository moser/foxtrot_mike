class GroupsController < ResourceController
  #prepend_before_filter :login_required
  def cost_overview
    model_by_id
    @from = get_date(:from)
    @to = get_date(:to)
    @from ||= @group.flights.last.try(:departure_date) || Date.today
    @to ||= @group.flights.first.try(:departure_date) || Date.today
    @group_cost = GroupCost.new(@group, @from, @to)
  end

private
  def get_date(key)
    begin
      Date.new(*params[:report].select { |k,v| k.include?(key.to_s) }.sort_by { |a| a.first }.map(&:last).map(&:to_i))
    rescue
    end
  end
end
