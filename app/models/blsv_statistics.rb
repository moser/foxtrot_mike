class BlsvStatistics
  attr_reader :group, :date

  def initialize(group, date)
    @group, @date = group, date
  end
  
  def by_year
    people.filter { |p| not p.birthdate.nil? }.group_by { |p| p.birthdate.year }.map do |y, v|
      [y, v.group_by(&:sex).map { |s, v| [s, v.count] }.sort_by { |a| a[0] }]
    end.sort_by { |a| a[0] }
  end


  private
  def people
    group.people.where(member: true, member_state: [ :active, :passive, :passive_with_voting_right ])
  end
end
