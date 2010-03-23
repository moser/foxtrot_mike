require("spec_helper.js");
require("../../public/javascripts/flight.js");

Screw.Unit(function(){
  describe("Flight", function(){
    describe("ArrivalHelper", function(){
      before(function() {
        $(".flight").each(function(i, e) {
          new ArrivalHelper(e);
        });
        $("#flight_departure_4i").val("11");
        $("#flight_departure_5i").val("00");
        $("#arrival").val("11:02");
        $("#flight_duration").val("0:02");
      });
      
      it("should calculate the duration when the arrival is changed", function(){
        var arrival = $("#arrival");
        arrival.val("11:22");
        arrival.blur();
        expect($("#flight_duration").val()).to(equal, "0:22");
      });
      
      it("should reset arrival if it is before the departure", function(){
        var arrival = $("#arrival");
        arrival.val("10:22");
        arrival.blur();
        expect($("#flight_duration").val()).to(equal, "0:00");
        expect($("#arrival").val()).to(equal, "11:00");
      });
      
      it("should calculate the duration when the departure is changed", function(){
        var departure_h = $("#flight_departure_4i");
        departure_h.val("10");
        departure_h.blur();
        expect($("#flight_duration").val()).to(equal, "1:02");
      });
        
      it("should calculate the arrival when the duration is changed", function(){
        var duration = $("#flight_duration");
        duration.val("0:20");
        duration.blur();
        expect($("#arrival").val()).to(equal, "11:20");
      });
    });
  });
});
