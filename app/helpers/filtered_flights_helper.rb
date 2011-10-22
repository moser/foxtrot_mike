module FilteredFlightsHelper
  def generate_filtered_flights_path(obj, from, to, group_by, aggregate_entries, format = :html)
    if obj.is_a?(Struct)
      filtered_flights_path(:format => format, 
                            :filter => { :from_parse_date => from.to_s, :to_parse_date => to.to_s }, :group_by => group_by, :aggregate_entries => aggregate_entries)
    else
      polymorphic_path([obj, :flights], :format => format, 
                       :filter => { :from_parse_date => from.to_s, :to_parse_date => to.to_s }, :group_by => group_by, :aggregate_entries => aggregate_entries)
    end
  end

  def group(flights, enable, &block)
    if enable
      flights = flights.dup
      while !flights.empty? do
        current = flights.first.aggregation_id
        g = [flights.delete_at(0)]
        while !flights.empty? && current && flights.first.aggregation_id == current
          g << flights.delete_at(0)
        end
        if g.length > 1
          haml_tag :div, :class => "aggregated_entry" do
            haml_tag :div, :class => "items" do
              g.each do |f|
                block.call(f)
              end
            end
            haml_tag :div, :class => "foot" do
              haml_tag :div, :class => "count" do
                concat("#")
                haml_tag :span, :class => "number" do
                  concat(g.length.to_s)
                end
              end
              haml_tag :div, :class => "sum" do
                haml_tag :span, :class => "number" do
                  concat(format_minutes(g.map(&:duration).sum))
                end
              end
            end
          end
        else
          block.call(g.first)
        end
      end
    else
      flights.each { |f| block.call f }
    end
  end
end
