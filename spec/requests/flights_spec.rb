require 'spec_helper'

describe "Flights" do
  describe "GET /flights" do
    it "shows flights" do
      flights = [ Flight.generate!, Flight.generate! ]
      visit flights_path
      flights.each do |f|
        page.should have_content(f.plane.registration)
        page.should have_content(f.seat1.person.name)
      end
    end
  end
end
