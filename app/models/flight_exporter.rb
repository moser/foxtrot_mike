require 'csv'

class FlightExporter
  include ApplicationHelper
  def initialize(flights)
    @flights = flights
  end

  def to_csv
    CSV.generate(encoding: 'UTF-8', col_sep: "\t") do |csv|
      csv << headers
      @flights.each do |flight|
        csv << [flight.id,
                flight.departure_date,
                flight.plane.registration,
                flight.seat1_person.name,
                flight.seat2_person.try(:name) || (flight.seat2_n > 0 ? flight.seat2_n : ''),
                flight.from.to_s,
                flight.to.to_s,
                flight.departure_time,
                flight.arrival_time,
                flight.duration / 60,
                flight.duration % 60,
                I18n.t("flight.launch_types.#{ flight.launch_kind }.short"),
                format_currency(flight.is_tow ? 0 : flight.free_cost_sum, false)]
      end
    end
  end

private
  def headers
    %w(ID Datum Kennzeichen Pilot Begleiter Von Nach Start Landung Stunden Minuten Startart Kosten)
  end
end
