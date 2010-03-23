replace_flight = function(event) {
  event.preventDefault();
  div = $(this).parent();
  div.append('<div class="disabler" />');
  $.get(this.href, function(html) {
    div.html(html);
    new ArrivalHelper(div);
  });
};

function ArrivalHelper(el) {
  this.flight_div = $(el);
  this.departure_h = $("#flight_departure_4i", this.flight_div);
  this.departure_m = $("#flight_departure_5i", this.flight_div);
  this.arrival = $("#arrival", this.flight_div);
  this.duration_hidden = $("#flight_duration", this.flight_div);
  this.duration_hidden.css("display", "none");
  this.duration = $('<input id="flight_duration_show" value="'+ Format.duration(this.duration_hidden.val()) +'"/>')
  this.duration.insertAfter(this.duration_hidden)
  this.departure_h.bind("blur", {self: this}, this.recalc_departure);
  this.departure_m.bind("blur", {self: this}, this.recalc_departure);
  this.arrival.bind("blur", {self: this}, this.recalc_arrival);
  this.duration.bind("blur", {self: this}, this.recalc_duration);
}
ArrivalHelper.prototype = {
  recalc: function(e, caller) {
    var self = e.data.self;
    var departure = {h: Parse.integer(String(self.departure_h.val())), m: Parse.integer(String(self.departure_m.val()))}
    var arrival = Parse.time(self.arrival.val());
    if(caller == "arrival" || caller == "departure") {
      if(departure && arrival) {
        var delta = 60 * (arrival.h - departure.h) + arrival.m - departure.m;
        if(delta < 0) {
          delta = 0;
          self.arrival.val(Format.time(departure));
        }
        self.duration.val(Format.duration(delta));
        self.duration_hidden.val(delta);
      }
    } else if(caller == "duration") {
      var duration = Parse.duration(self.duration.val());
      if(duration) {
        self.arrival.val(Format.time(Time.add(departure, duration)));
        self.duration_hidden.val(duration);
      } else {
        self.recalc_arrival(e);
      }
    }
  },
  recalc_duration: function(e) {
    e.data.self.recalc(e, "duration");
  },
  recalc_arrival: function(e) {
    e.data.self.recalc(e, "arrival");
  },
  recalc_departure: function(e) {
    e.data.self.recalc(e, "departure");
  },
};

function DateHelper(el) {
  
}

$(function() {
  $('.replace_flight').live('click', replace_flight);
  //TODO catch submit on flight forms and just replace
  //     and catch links on index and replace
  $('div.flight').each(function(i, el) {
    new ArrivalHelper(el);
  });
});
