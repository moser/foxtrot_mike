function ArrivalHelper(el) {
  var self = this;
  this.flight_div = $(el);
  DateTimePickers.replaceAndAttachPickersManually($(".input.time.departure", this.flight_div), "time",
                  function(e) {
                    self.departure = e;
                    e.timepicker({ onClose: function() { 
                      self.recalc_departure({ data: { self: self } });
                    }, constrainInput: false });
                    return e;
                  });
  DateTimePickers.replaceAndAttachPickersManually($(".input.time.arrival", this.flight_div), "time",
                  function(e) {
                    self.arrival = e;
                    e.timepicker({ onClose: function() { 
                      self.recalc_arrival({ data: { self: self } });
                    }, constrainInput: false });
                    return e;
                  });
  this.duration_hidden = $("#flight_duration", this.flight_div);
  this.duration_hidden.hide();
  this.duration = $('<input id="flight_duration_show" value="'+ Format.duration(this.duration_hidden.val()) +'"/>')
  this.duration.insertAfter(this.duration_hidden)
  this.duration.bind("blur", {self: this}, this.recalc_duration);
}
ArrivalHelper.prototype = {
  recalc: function(e, caller) {
    var self = e.data.self;
    var departure = Parse.time(self.departure.val());
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

function Days() {
  var self = this;
  this.waitingFor = {};
  this.modalWaitingFor = {};
  this.preLoadCount = 10;
  this.preLoadDistance = 5; //distance to the next gap when the gap should be closed by preloading
  this.reloadAge = 300000; //age of day obj in milliseconds when it should be reloaded
  this.preLoading = {};
  this.elements = {};
  this.callbackFor = function(key) {
    if(this.modalWaitingFor[key]) {
      this.modalWaitingFor[key].forEach(function(e) { e(self.elements[key]); });
      PleaseWait.vote_modal_hide();
    }
    if(this.waitingFor[key]) {
      this.waitingFor[key].forEach(function(e) { e(self.elements[key], true); });
    }
    this.modalWaitingFor[key] = null;
    this.waitingFor[key] = null;
  };
  this.addCallbackFor = function(key, callback, modal) {
    if(callback) {
      var o = this.waitingFor;
      if(modal) { o = this.modalWaitingFor; }
      if(!o[key]) { o[key] = []; }
      o[key].push(callback);
    }
  }
  this.get = function(key, callback) {
    if(!this.present(key)) {
      this.load(key, callback);
      return null;
    }
    var d = this.elements[key].keyDate;
    var k = this.next_gap(key);
    if((Parse.date_to_s(k) - d) / 86400000 < this.preLoadDistance) {
      this.preLoad(k, "plus");
    }
    k = this.prev_gap(key);
    if((d - Parse.date_to_s(k)) / 86400000 < this.preLoadDistance) {
      this.preLoad(k, "minus");
    }
    if((new Date() - this.elements[key].loaded) > this.reloadAge) {
      this.reload(key, callback);
    }
    console.log(this.elements[key].dom.html().length);
    return this.elements[key];
  };
  this.add = function(day) {
    this.elements[day.key] = day;
    this.callbackFor(day.key);
  };
  this.load = function(key, callback) {
    PleaseWait.vote_modal_show();
    this.addCallbackFor(key, callback, true);
    $.ajax({url: "/flights?day_parse_date=" + key + "&plus_days=" + this.preLoadCount + "&minus_days=" + this.preLoadCount,
      success: function(html, status, xhr) {
        self.extract("<div>" + html + "</div>");
        PleaseWait.vote_modal_hide();
      }
    });
  };
  this.reload = function(key, callback) {
    console.log("reloading " + key);
    PleaseWait.vote_show();
    this.addCallbackFor(key, callback, false);
    $.ajax({url: "/flights?day_parse_date=" + key + "&plus_days=" + this.preLoadCount + "&minus_days=" + this.preLoadCount,
      success: function(html, status, xhr) {
        self.extract("<div>" + html + "</div>");
        PleaseWait.vote_hide();
      }
    });
  };
  this.preLoad = function(key, dir) {
    console.log("preloading " + key + " " + dir);
    if(!this.preLoading[key]) { this.preLoading[key] = {}; }
    if(!this.preLoading[key][dir]) {
      this.preLoading[key][dir] = true;
      PleaseWait.vote_show();
      $.get("/flights?day_parse_date=" + key + "&" + dir + "_days=" + this.preLoadCount, function(html) {
        self.extract("<div>" + html + "</div>");
        PleaseWait.vote_hide();
        self.preLoading[key][dir] = false;
      });
    }
  };
  this.present = function(key) {
    return !!this.elements[key];
  };
  this.next_gap = function(key) {
    while(this.present(key)) {
      key = this.elements[key].next_key;
    }
    return key;
  };
  this.prev_gap = function(key) {
    while(this.present(key)) {
      key = this.elements[key].prev_key;
    }
    return key;
  };
  this.extract = function(d) {
    d = $(d);
    d.find(".day").each(function(i, e) {
      self.add(new Day($(e)));
    });
    return d;
  };  
}

function Day(dom) {
  this.dom = dom;
  this.loaded = new Date();
  this.key = dom.attr("id");
  this.keyDate = Parse.date_to_s(this.key);
  // 90000000ms = 25h
  // 82800000ms = 23h
  // Parse.date_to_s returns a Date with time = 0:00
  // when Date is 31.10.xxxx, (Date + 24h) is still 31.10.xxxx because of DST, thus add 
  // 25h which is the next day in every case.
  // Same for prev_key with the starting date of DST.
  // Date in JS sucks...
  this.next_key = Format.date_to_s(new Date(Parse.date_to_s(this.key).getTime() + 90000000));
  this.prev_key = Format.date_to_s(new Date(Parse.date_to_s(this.key).getTime() - 82800000));
}

function CacheEntry(path, dom) {
  this.dom = dom;
  this.loaded = new Date();
  this.key = path;
}

var Flights = {
  per_page: 20,
  days: new Days(),
  rootDayKey: "",
  cache: {},
  init: function() {
    $(".dc .scrollable").scrollable({vertical : true, mousewheel: true, item: ".day_link", speed: 200});
    $('a.scroll_days_down').live('click', function(e) {
      var s = $('.dc .scrollable').data('scrollable');
      if(s.getIndex() > s.getSize() - 15) {
        s.end();
      } else {
        s.move(14);
      }
      return false;
    });
    $('a.scroll_days_up').live('click', function(e) {
      var s = $('.dc .scrollable').data('scrollable');
      if(s.getIndex() < 14) {
        s.begin();
      } else {
        s.move(-14);
      }
      return false;
    });

    $("a.down").live("click", function(e) { 
      if(!e.ctrlKey) {
        if(Flights.scrollable.getIndex() > Flights.scrollable.getSize() - Flights.per_page) {
          Flights.goto_day(Flights.current_day.prev_key, true);
        } else {
          Flights.scrollable.move(1);
        }
        return false;
      }
    });
    $("a.up").live("click", function(e) {
      if(!e.ctrlKey) {
        if(Flights.scrollable.getIndex() == 0) {
          Flights.goto_day(Flights.current_day.next_key, true);
        } else {
          Flights.scrollable.move(-1);
        }
        return false;
      }
    });

    $(".day_link a").live("click", function(e) {
      if(!e.ctrlKey) {
        Flights.goto_day($(e.target).attr("data-date"), true);
        return false;
      }
    });
    window.onpopstate = function(e) {
      if(e.state && e.state.day) {
        console.log("nav to " + e.state.day);
        Flights.goto_day(e.state.day); 
      } else if(e.state && e.state.path) { //use the url fragment
        console.log("nav to " + e.state.path);
        Flights.goto_url(e.state.path);
      }
    };
    Flights.days.extract($(".flights"));
    if(window.location.pathname.match(/^\/flights$/) ||
       window.location.pathname.match(/^\/flights\/$/) || 
       window.location.pathname.match(/^\/flights\/day/)) {
      //index
      Flights.current_day = Flights.days.get($(".flights").attr("data-current_day"));
      Flights.goto_day(Flights.current_day.key, false, true);
    } else {
      //some flight, edit or new
      Flights.goto_url(window.location.pathname, false, true);
      //load the current day in BG
      Flights.current_day = { key: $(".flights").attr("data-current_day") };
      Flights.days.reload($(".flights").attr("data-current_day"), function(d) { Flights.current_day = d; });
    }
  },
  goto_day: function(key, doState, first) {
    if (doState) { window.history.pushState({ day: key }, "", "/flights/day/" + key); }
    if(first) { window.history.replaceState({ day: key }, "", "/flights/day/" + key); }
    var f = function(d, highlight) { 
      if(d) {
        $(".item_container").hide();
        $(".list").show();
        if(!highlight || Flights.current_day.key == d.key) {
          Flights.current_day = d;
          $(".flights .day").remove();
          $(".flights").html(d.dom);
          if(highlight) { $(".flights .day .flight").effect("highlight", {}, 3000); }
          $(".dc div.day_link.current").removeClass("current");
          $('.dc .scrollable').data('scrollable').seekTo(
            $('.dc .scrollable').data('scrollable').getItems().
              index($(".dc div.day_link[data-date=" + d.key + "]").addClass("current")));
          Flights.scrollable = $(".flights .day").scrollable({vertical : true, mousewheel: true, item: ".flight", onBeforeSeek: function(e, i) {
            if(i > (e.target.getSize() - Flights.per_page + 1)) {
              if(e.target.getIndex() < (e.target.getSize() - Flights.per_page + 1)) {
                e.target.seekTo(e.target.getSize() - Flights.per_page + 1);
              }
              return false;
            }
	        }, speed: 200}).data("scrollable");
          Flights.scrollable.begin();
        };
      }
    };
    f(Flights.days.get(key, f), false);
  },
  goto_url: function(url, doState, first) {
    var urlregex = /^http\:\/\/[a-zA-Z0-9\-\.]+(\:\d+)*(\/\S*)?$/
    var pathregex = /^(\/\S*)?$/
    m = url.match(urlregex)
    if(m) { url = m[2]; }
    if(url.match(pathregex)) {
      var f = function(html) {
        $(".item_container").html(html);
        DomInsertionWatcher.notify_listeners($('.item_container'));
        $(".list").hide();
        $(".item_container").show();
      };
      if(first) { Flights.cache[url] = new CacheEntry(url, $(".item_container").children()); }
      if(Flights.cache[url]) {
        f(Flights.cache[url].dom);
        if(doState) { window.history.pushState({ path: url }, "lala", url); }
        if(first) { window.history.replaceState({ path: url }, "lala", url); }
        
        // Reload only if older than 60s
        // TODO reload for edit or don't cache edit?
        if(new Date - Flights.cache[url].loaded > 60000) {
          PleaseWait.vote_show();
          $.get(url, function(html) {
            if(window.location.pathname == url) {
              f(html);
              $(".item_container").effect("highlight", {}, 3000);
            }
            PleaseWait.vote_hide();
            Flights.cache[url] = html;
          });
          }
      } else {
        PleaseWait.vote_modal_show();
        $.get(url, function(html) {
          f(html);
          if(doState) { window.history.pushState({ path: url }, "lala", url); }
          if(first) { window.history.replaceState({ path: url }, "lala", url); }
          PleaseWait.vote_modal_hide();
          Flights.cache[url] = new CacheEntry(url, html);
        });
      }
    }
  }
};


$(function() {
  if($(".list").size() > 0) { //only if the list div is present
    Flights.init();
    var f = function(e) { if(!e.ctrlKey) {
        Flights.goto_url(this.href, true);
        return false; 
      }
    };
    $('a.sop.show').live('click', f);
    $('a.sop.new').live('click', f);
    $('a.sop.edit').live('click', f);
    $('a.sop.back.index').live('click', function(e) { if(!e.ctrlKey) {
        Flights.goto_day(Flights.current_day.key, true);
        return false; 
      }
    });
    
  }
  var f = function() {
    $('div.flight_form').each(function(i, el) {
      new ArrivalHelper(el);
    });
  };
  DomInsertionWatcher.register(f);
  f();
});

