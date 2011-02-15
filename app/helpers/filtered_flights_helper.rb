module FilteredFlightsHelper
  def generate_filtered_flights_path(obj, from, to, group_by, format = :html)
    if obj.is_a?(Struct)
      filtered_flights_path(:format => format, 
                            :filter => { :from_parse_date => from.to_s, :to_parse_date => to.to_s }, :group_by => group_by)
    else
      polymorphic_path([obj, :flights], :format => format, 
                       :filter => { :from_parse_date => from.to_s, :to_parse_date => to.to_s }, :group_by => group_by)
    end
  end
end
