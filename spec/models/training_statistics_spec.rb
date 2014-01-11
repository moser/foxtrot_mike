require 'spec_helper'

describe TrainingStatistics do
  let(:gliders) { LegalPlaneClass.create(name: 'glider') }
  let(:glider) { Plane.generate!(legal_plane_class: gliders) }
  let(:tow_plane) { Plane.generate! }
  let(:student) { Person.generate!.tap { |o| o.licenses.create(name: 'GPL', valid_from: 2.years.ago, level: 'student', legal_plane_classes: [gliders]) } }
  let(:pilot) { Person.generate!.tap { |o| o.licenses.create(name: 'GPL', valid_from: 2.years.ago, level: 'normal', legal_plane_classes: [gliders]) } }
  let(:wire_launcher) { WireLauncher.generate! }
  let(:flights) do
    [ Flight.generate!(plane: glider, seat1_person: student, duration: 1, launch: WireLaunch.new(wire_launcher: wire_launcher)),
      Flight.generate!(plane: glider, seat1_person: pilot,   duration: 100, launch: WireLaunch.new(wire_launcher: wire_launcher)),
      Flight.generate!(plane: glider, seat1_person: student, duration: 2, launch: F.build(:tow_flight, plane: tow_plane)),
      Flight.generate!(plane: glider, seat1_person: student, duration: 3),
      Flight.generate!(plane: tow_plane, seat1_person: student)
    ]
  end
  subject { TrainingStatistics.new(flights, gliders) }

  it "filters the given flights to be just training flights" do
    subject.training_flights.length.should == 3
  end

  it "calculates the count of wire launches" do
    subject.wire_launch_count.should == 1
  end

  it "calculates the count of tow launches" do
    subject.tow_launch_count.should == 1
  end

  it "calculates the count of self launches" do
    subject.self_launch_count.should == 1
  end

  it "calculates the flight time" do
    subject.flight_time.should == 6
  end
end
