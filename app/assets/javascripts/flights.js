function TimeHelper(el) {
  this.flight_div = $(el);
  this.departure = this.flight_div.find("input#flight_departure_time");
  this.tow_flight = false;
  if(this.departure.length == 0) { //tow flight
    this.departure = this.flight_div.find("span.departure_time");
    this.arrival = this.flight_div.find("input#launch_tow_flight_arrival_time");
    this.tow_flight = true;
  } else {
    this.arrival = this.flight_div.find("input#flight_arrival_time");
    this.departure.blur({ self: this }, this.recalc);
  }
  this.duration = this.flight_div.find("span.duration");
  this.arrival.blur({ self: this }, this.recalc);
}
TimeHelper.prototype = {
  recalc: function(e) {
    var self = e.data.self;
    var departure = Parse.time(self.getDepartureTime());
    var arrival = Parse.time(self.arrival.val());
    if(!self.tow_flight)
      self.departure.val(Format.time(departure));
    self.arrival.val(Format.time(arrival));
    if(departure && arrival) {
      var delta = 60 * (arrival.h - departure.h) + arrival.m - departure.m;
      self.duration.html(Format.duration(delta));
    }
  },
  getDepartureTime: function() {
    if(this.tow_flight) 
      return this.departure.html();
    else
      return this.departure.val();
  }
};

function Days() {
  var self = this;
  this.waitingFor = {};
  this.modalWaitingFor = {};
  this.preLoadCount = 10;
  this.preLoadDistance = 5; //distance to the next gap when the gap should be closed by preloading
  this.reloadAge = 300000; //age of day obj in milliseconds when it should be reloaded
  this.preLoading = {};
  this.elements = {};
  this.invalidatedDays = [];
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
    //console.log(this.elements[key].dom.html().length);
    return this.elements[key];
  };
  this.add = function(d) {
    this.elements[d.key] = d;
    var c = d.count();
    if(c == 0) {
      e = $("#day_link-" + d.key);
      if(Flights.current_day.key == d.key) {
        to = false;
        if(e.prevAll(".day_link").length > 0) {
          to = e.prevAll(".day_link").first().attr("data-date");
        } else if(e.nextAll(".day_link").length > 0) {
          to = e.nextAll(".day_link").first().attr("data-date");
        } else {
          to = d.key;
        }
        Flights.goto_day(to, false, true);
      }
      e.remove();
    } else {
      if($("#day_link-" + d.key).length == 0) {
        var newday = $('<div data-date="'+ d.key +'" class="day_link" id="day_link-'+ d.key +'"><a href="/flights/day/'+ d.key +'" data-date="'+ d.key +'">'+ Format.date_short(Parse.date_to_s(d.key)) +' <span class="count">('+ c +')</span></a></div>');
        var after = $(".day_links div").filter(function() { return $(this).data("date") > d.key }).last();
        (after.length > 0 ?
          after.after(newday)
          : $(".day_links").prepend(newday)).effect("highlight", {}, 3000);
      }
      $("#day_link-" + d.key + " .count").html("(" + c + ")");
      this.callbackFor(d.key);
    }
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
    //console.log("reloading " + key);
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
    //console.log("preloading " + key + " " + dir);
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
  this.invalidate_day = function(key) {
    if(!this.present(key)) {
      this.elements[key] = new Day($('<div class="day alternate" id="'+ key +'"><div class="flight"/></div>')); //add element with one flight
    }
    this.elements[key].loaded = new Date(new Date() - 86400000);
    this.invalidatedDays.push(key);
  };
  this.reloadInvalidated = function() {
    for(i = 0; i < this.invalidatedDays.length; i++) {
      this.reload(this.invalidatedDays[i], function() {});
    }
    this.invalidatedDays = [];
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
  this.count = function() {
    return $(this.dom).find(".flight").length;
  }
}

function CacheEntry(path, dom) {
  var self = this;
  this.dom = dom;
  this.loaded = new Date();
  this.key = path;
}

var Flights = {
  per_page: 20,
  days: new Days(),
  rootDayKey: "",
  current_day: "",
  current_view: "",
  cache: {},
  init: function() {
    $(".day_link a").live("click", function(e) {
      if(!e.ctrlKey) {
        Flights.goto_day($(this).attr("data-date"), true);
        return false;
      }
    });
    $(window).bind("popstate", function(e) {
      if(e.originalEvent && e.originalEvent.state) {
        state = window.History.getState().data;
        if(state && state.day) {
          //console.log("nav to " + state.day);
          Flights.goto_day(state.day); 
        } else if(state && state.path) { //use the url fragment
          //console.log("nav to " + state.path);
          Flights.goto_url(state.path);
        }
      }
    });
    Flights.days.extract($(".flights"));
    if(window.location.pathname.match(/^\/flights$/) ||
       window.location.pathname.match(/^\/flights\/$/) || 
       window.location.pathname.match(/^\/flights\/day/)) {
      //index
      Flights.current_day = Flights.days.get($(".flights").attr("data-current_day"));
      Flights.current_view = "list";
      Flights.goto_day(Flights.current_day.key, false, true);
    } else {
      //some flight, edit or new
      Flights.goto_url(window.location.pathname, false, true);
      //load the current day in BG
      Flights.current_day = { key: $(".flights").attr("data-current_day") };
      Flights.current_view = "item";
      Flights.days.reload($(".flights").attr("data-current_day"), function(d) { Flights.current_day = d; });
    }
  },
  menu_link_clicked: function() {
    if(Flights.current_view != "list") {
      Flights.goto_day(Flights.current_day.key, true);
      return false;
    }
  },
  goto_day: function(key, doState, first) {
    //console.log(key + " " + Flights.current_day.key);
    if(key == Flights.current_day.key && !first && Flights.current_view == "list") {
      Flights.days.invalidate_day(key);
      doState = false;
    }
    if (doState) { Flights.doState("push", { day: key }, "/flights/day/" + key); }
    if(first) { Flights.doState("replace", { day: key }, "/flights/day/" + key); }
    var f = function(d, highlight) {
      if(d && Flights.current_view == "list") {
        $(".item_container").hide();
        $(".list").show();
        if(!highlight || Flights.current_day.key == d.key) {
          Flights.current_day = d;
          $(".flights .day").remove();
          $(".flights").html(d.dom);
          if(highlight) { $(".flights .day .flight").effect("highlight", {}, 3000); }
          $("div.day_link.current").removeClass("current");
          $("div.day_link[data-date="+ d.key +"]").addClass("current")
        }
        Flights.days.reloadInvalidated();
      }
    };
    Flights.current_view = "list";
    f(Flights.days.get(key, f), false);
  },
  goto_url: function(url, doState, first) {
    if(url = Flights.extract_path(url)) {
      var f = function(html) {
        if(Flights.current_view == "item") {
          $(".item_container").html($(html).filter(".item_container").children());
          DomInsertionWatcher.notify_listeners($('.item_container'));
          $(".list").hide();
          $(".item_container").show();
        }
      };
      Flights.current_view = "item";
      if(first) { Flights.cache[url] = new CacheEntry(url, $(".item_container")); }
      if(Flights.cache[url]) {
        f(Flights.cache[url].dom);
        if (doState) { Flights.doState("push", { path: url }, url); }
        if(first) { Flights.doState("replace", { path: url }, url); }
        // Reload only if older than 60s
        // TODO reload for edit or don't cache edit?
        if(new Date - Flights.cache[url].loaded > 60000) {
          PleaseWait.vote_show();
          $.get(url, function(html) {
            PleaseWait.vote_hide();
            Flights.cache[url] = new CacheEntry(url, html);
            if(window.History.getState().data.path == url) {
              f(Flights.cache[url].dom);
              $(".item_container").effect("highlight", {}, 3000);
            }
          });
        }
      } else {
        PleaseWait.vote_modal_show();
        $.get(url, function(html) {
          if (doState) { Flights.doState("push", { path: url }, url); }
          if(first) { Flights.doState("replace", { path: url }, url); }
          Flights.cache[url] = new CacheEntry(url, html);
          f(Flights.cache[url].dom);
          PleaseWait.vote_modal_hide();
        });
      }
    }
  },
  invalidate_cache: function(url) {
    //console.log("invalidate_cache " + url);
    url = Flights.extract_path(url);
    if(url && !!Flights.cache[url])
      Flights.cache[url].loaded = new Date(new Date() - 86400000);
  },
  extract_path: function(url) {
    var urlregex = /^http\:\/\/[a-zA-Z0-9\-\.]+(\:\d+)*(\/\S*)?$/;
    var pathregex = /^(\/\S*)?$/;
    m = url.match(urlregex);
    if(m) { url = m[2]; }
    if(url.match(pathregex))
      return url;
    else
      return false;
  },
  doState: function(method, data, url) {
    //console.log("pushState " + url);
    window.History[method + "State"](data, window.document.title, url);
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
        Flights.goto_day($(".item_container .item").data("departure_date"), true);
        return false; 
      }
    });
    $('li.flights_menu_link').children('a').click(function(e) {
      return Flights.menu_link_clicked();
    });

    $('a.inline_form_show').live('click', function(e) {
      var t = $(e.target);
      Flights.invalidate_cache(t.parents(".item").data("path"));
      Flights.days.invalidate_day(t.parents(".item").data("departure_date"));

      $('form.edit').live('submit', function(e) {
        var d = Parse.date($(e.target).find("input#flight_departure_date").val());
        if(d)
          Flights.days.invalidate_day(Format.date_to_s(d));
      });
    });
  }

  $("#facebox a.cancel").live("click", function(e) {
    $(document).trigger('close.facebox');
    return false;
  });
  $("form.destroy_confirmation").live("submit", function(e) {
    var form = $(e.target);
    Flights.days.invalidate_day(Flights.current_day.key);
    $.ajax({url: form.attr('action'),
          data: form.serialize(),
          type: 'POST',
          success: function(html, status, xhr) {
            PleaseWait.vote_modal_hide();
            Flights.goto_day(Flights.current_day.key, false, true);
            $(document).trigger('close.facebox');
          }
    });
    PleaseWait.vote_modal_show();
    return false;
  });

  var f = function() {
    $('div.flight_form').each(function(i, el) {
      new TimeHelper(el);
      if($(el).find("#flight_plane_id").length > 0) {
        new PlaneHelper(el);
        new CrewHelper(el);
        new AirfieldHelper(el, "from");
        new AirfieldHelper(el, "to");
        new PersonHelper(el, "controller", null, false);
      } else { //tow_flight form
        new TowPlaneHelper(el, "tow_flight");
        new CrewHelper(el, "tow_flight");
        new AirfieldHelper(el, "to", "tow_flight");
      }
    });
    $('form#launch_form').each(function(i, el) {
      new TimeHelper(el);
      new TowPlaneHelper(el);
      new CrewHelper(el, "launch[tow_flight]");
      new AirfieldHelper(el, "to", "launch[tow_flight]");
      new PersonHelper(el, "operator", null, true, "launch[wire_launch]");
    });
    $('.flight_form.new').bind('submit', function(e) {
      var form = $(e.target);
      $.ajax({url: form.attr('action'),
            data: form.serialize(),
            type: 'POST',
            success: function(html, status, xhr) {
              Flights.days.invalidate_day(Format.date_to_s(Parse.date($("input#flight_departure_date").val())));
              PleaseWait.vote_modal_hide();
              Flights.goto_url(html, true, false);
            },
            error: function(xhr, status) {
              $('.item_container').replaceWith($(xhr.responseText));
              DomInsertionWatcher.notify_listeners($('.flight_form.new'));
              PleaseWait.vote_modal_hide();
              return false;
            }
      });
      PleaseWait.vote_modal_show();
      return false;
    });
  };
  DomInsertionWatcher.register(f);
  f();
});

