require 'csv'

LAUNCH_TYPES = {
  nil => 1,
  "AbstractFlight" => 3,
  "WireLaunch" => 5
}

def export(from, to)
  CSV do |csv|
    csv << ["callsign", "pilotname", "attendantname", "departuretime", "departurelocation", "arrivaltime", "arrivallocation", "flighttime", "landingcount", "starttype", "flightmode", "motorstart", "motorend", "towheight", "towtime", "chargemode", "invoiced", "comment", "towcallsign", "towpilotname", "ftid", "km", "planewkz", "planedesignation", "wid", "uidwinch", "attendantname2", "attendantname3", "offblock", "onblock"]
    Flight.where("departure_date between ? and ?", from, to).order(:departure_date, :departure_i).each do |flight|
      #callsign	pilotname	attendantname	departuretime	departurelocation	arrivaltime	arrivallocation
      #D-XXXX	Nachname, Vorname (Pilot)	Nachname, Vorname (Begleiter)	Datum und Zeit (Start)	Startort	Datum und Zeit (Landung)	Landeort
      #flighttime	landingcount	starttype	flightmode	motorstart	motorend	towheight
      #Zeit in Minuten	Anzahl de Landungen	1=Eigenstart, 3=F-Schlepp, 5=Winde	1=Lokal,2=Nur Abflug, Nur Landung,4=Fremder Platz			Schlepph�he in m
      #Schleppzeit in Minuten	Abrechnungsart(1=Keine,2=Pilot,3=Begleiter,4=Gast,5=Pilot+Begleiter,6Gastflug(Pilot zahlt),7=Anderes Mitglied)	0=Nicht abgerechnet,3= teilweise Abgerechnet, 255=Abgerechnet	Kommentar	Schleppmaschine	Schlepppilot	Flugart(zwischen 1 und 20)3=F-Schlepp,8=Schulflug,10=Privatflug)	Strecke in Km	Wettbewerbskennzeichen	Flugzeugbeschreibung	Winde	Windenfahrer	weiterer Begleiter	weiterer Begleiter	Uhrzeit offblock	Uhrzeit Onblock
      #towtime	chargemode	invoiced	comment	towcallsign	towpilotname	ftid	km	planewkz	planedesignation	wid	uidwinch	attendantname2	attendantname3	offblock	onblock
      row = [
        flight.plane.registration,
        "#{flight.seat1_person.lastname}, #{flight.seat1_person.firstname}",
      ]
      if flight.seat2_person
        row += ["#{flight.seat2_person.lastname}, #{flight.seat2_person.firstname}"]
      elsif flight.seat2_n > 0
        row += ["+#{flight.seat2_n}"]
      else
        row += [nil]
      end
      row += [
        flight.departure,
        flight.from,
        flight.arrival,
        flight.to,
        flight.duration,
        1, # landings
        LAUNCH_TYPES[flight.launch_type],
      ]
      flight_type = 4
      if flight.from == Airfield.home and flight.to == Airfield.home
        flight_type = 1
      elsif flight.from == Airfield.home
        flight_type = 2
      elsif flight.to == Airfield.home
        flight_type = 3
      end
      row += [
        flight_type,
      ]
      if flight.engine_duration > 0
        row += [
          flight.departure,
          flight.departure + flight.engine_duration.minutes
        ]
      else
        row += [
          nil, nil
        ]
      end
      charge_mode = 1
      invoiced = 255
      if flight.launch_type == "AbstractFlight"
        row += [
          0, #tow height
          flight.launch.duration,
          charge_mode,
          invoiced,
          flight.launch.plane.registration,
          "#{flight.launch.seat1_person.lastname}, #{flight.launch.seat1_person.firstname}",
        ]
      else
        row += [
          nil, nil,
          charge_mode,
          invoiced,
          nil, nil
        ]
      end
      ftid = 10 # private flight
      row += [
        flight.comment,
        ftid,
        nil, # km
        nil, # wkz
        flight.plane.make,
      ]
      if flight.launch_type == "WireLaunch"
        row += [flight.launch.wire_launcher]
        if not flight.launch.operator.nil?
          row += ["#{flight.launch.operator.lastname}, #{flight.launch.operator.firstname}"]
        else
          row += [nil]
        end
      else
        row += [
          nil, nil
        ]
      end

      row += [
        nil, nil,
        flight.departure,
        flight.arrival
      ]

      csv << row
    end
  end
end

#export(Date.new(2015, 6, 1), Date.new(2015, 6, 30))
