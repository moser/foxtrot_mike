function Range(from, to) {
  if(from > to) {
    this.from = to;
    this.to = from;
  } else {
    this.from = from;
    this.to = to;
  }
};

Range.prototype = {
  lt: function(other) {
    return this.from > other.from || this.to < other.to;
  },
  gt: function(other) {
    return other.lt(this);
  },
  minus: function(other) {
    var result = {};
    if(this.from < other.from) { 
      var d = new Date(other.from); 
      d.setDate(d.getDate() - 1); 
      result.lower = new Range(this.from, d); 
    }
    if(this.to > other.to) {
      var d = new Date(other.to); 
      d.setDate(d.getDate() + 1); 
      result.upper = new Range(d, this.to); 
    }
    return result;
  },
  unite: function(other) {
    var from = this.from;
    var to = this.to;
    if(other.from < from) { from = other.from; }
    if(to < other.to) { to = other.to; }
    return new Range(from, to);
  },
  eq: function(other) {    
    return !(this.lt(other) || this.gt(other));
  },
  to_s: function() {
    return this.from + ' - ' + this.to;
  }
};

var Aggregate = {
  aggregateEntries: function() {
  flightContainer = $(".flights");
  a = flightContainer.find(".flight").first();
  i = 0
  while(a.length > 0) {
    e = a.nextUntil("[data-aggregation_id!=" + a.data("aggregation_id") + "]").andSelf();
    if(e.length > 1 && a.data("aggregation_id") != undefined) {
      g = $("#aggregated_entry-prototype .aggregated_entry").clone();
      a.before(g);
      g.attr("id", "" + a.data("aggregation_id") + "_" + i);
      g.find(".items").append(e);
      g.find(".foot .count .number").text(e.length);
      sum = 0;
      e.each(function() {
        sum = sum + parseInt($(this).data("duration"));
      })
      g.find(".foot .sum .number").text(Format.duration(sum));
      i++;
    }
    e.addClass("processed");
    a = flightContainer.find(".flight:not(.processed)").first();
  }
  $(".processed").removeClass("processed");
  $("a.toggle_hide_flights").click(function(e) {
    $(e.target).parents(".aggregated_entry").toggleClass("hide_flights");
    return false;
  });
  },

  unaggregateEntries: function () {
  $(".group_container .aggregated_entry").each(function() {
    $(this).before($(this).find(".flight")).remove();
  });
  },
  check: function() {
    if($("#aggregate_entries").is(":checked")) {
      Aggregate.aggregateEntries();
    } else {
      Aggregate.unaggregateEntries();
    }
  }
};

var Groupable = {
  headers: {},
  current_group: 'none',

  getHeaders: function (type) {
    if(Groupable.headers[type])
      return Groupable.headers[type];
    PleaseWait.vote_show();
    $.ajax({ url: '/headers.json?for=' + type,
             dataType: 'json',
             async: false,
             success: function(d) { Groupable.headers[type] = d; }});
    PleaseWait.vote_hide();
    return Groupable.headers[type];
  },

  click_group_by: function(e) {
    try { 
      Groupable.change_group_by($(e.target).attr('data-group_by'));
    } catch(e) {};
    return false;
  },

  items_changed: function() {
    Groupable.change_group_by(Groupable.current_group);
  },

  change_group_by: function(group_by) {
    Aggregate.unaggregateEntries();
    if(Groupable.current_group != null && $(".flight").length > 0) {
      $('.group_container').append($("#" + $.unique($(".flight").map(function(i,e) { return $(e).attr("id"); })).toArray().join(":first, #") + ":first")).find('.group').remove();
    }
    Groupable.current_group = group_by;
     if(group_by != 'none') {
      var h = Groupable.getHeaders(group_by);
      var groups = [];
      $(':not(.hidden).groupable').each(function(i, e) {
        var new_groups = $(e).attr('data-' + group_by);
        if(new_groups != '') {
          if(/,/.exec(new_groups)) {
            var m = /(?:\((.+)\),)*\((.+)\)$/.exec(new_groups);
            m.shift();
            new_groups = m;
          } else {
            new_groups = [/\((.+)\)/.exec(new_groups)[1]];
          }
          for(var i = 0; i < new_groups.length; i++) {
            if($.inArray(new_groups[i], groups) == -1) {
              groups.push(new_groups[i]);
            }
          }
        }
      });
      for(var i = 0; i < groups.length; i++) {
        var group = groups[i];
        var group_div = $('#group-prototype .group').clone().attr("id", group);
        var div = group_div.find('.items');
        var groupables = $(':not(.hidden).groupable[data-' + group_by + '*="(' + group + ')"]');
        group_div.find('.foot .count .number').text(groupables.length);
        group_div.find('.head .title').text(h[group].title);
        group_div.find('.head .hint').text(h[group].line);
        groupables.each(function (i, e) {
          if($(e).parents('.group').length > 0) {
            var id = $(e).attr('id');
            div.append($(e).clone());
          } else {
            div.append(e);
          }
        });
        div.find('.groupable').sortElements(function(a, b) { return parseInt($(a).attr('data-sort')) > parseInt($(b).attr('data-sort')) ? 1 : -1; });
        if(Groupable.group_callback) { Groupable.group_callback.call(group_div); }
        $('.group_container').append(group_div);
      }
      $(".filtered_flights > .foot").hide();
    } else {
      $('.group_container').find('.groupable').sortElements(function(a, b) { return parseInt($(a).attr('data-sort')) > parseInt($(b).attr('data-sort')) ? 1 : -1; });
      $(".filtered_flights > .foot").show();
    }
    Aggregate.check();
  },

  init: function(group_callback) {
    Groupable.group_callback = group_callback;
    $('a.group_by').live('click', Groupable.click_group_by);
    $('a.toggle_no_print').live('click', function(e) { 
      $(e.target).parents('.group').toggleClass('print_off'); 
      return false; 
    });
    $('a.toggle_collapsed').live('click', function(e) { 
      $(e.target).parents('.group').toggleClass('collapsed'); 
      return false; 
    });
  },
  
};

var Book = {
  dates: {},
  loaded_range: null,
  update_flights: function(range) {
    if(Book.loaded_range.lt(range)) {
      var diff = range.minus(Book.loaded_range);
      if(diff.lower) { Book.load_and_show_flights(diff.lower); }
      if(diff.upper) { Book.load_and_show_flights(diff.upper); }
    } else {
      Book.show_range = range;
      Book.hide_flights();
    }
    $('h2.page_sub_title').text(Format.date_short(range.from) + " - " + Format.date_short(range.to));
  },

  load_and_show_flights: function(range) {
    $.get('', { 'filter[from_parse_date]': Format.date_short(range.from),
            'filter[to_parse_date]': Format.date_short(range.to) },
          function(html) {
            $('.flights').append($(html));
            Book.loaded_range = Book.loaded_range.unite(range);
            Book.show_range = Book.show_range.unite(range);
            Book.find_dates();
            Book.hide_flights();
            PleaseWait.vote_hide();
          });
    PleaseWait.vote_show();
  },

  hide_flights: function() {
    for(id in Book.dates) {
      if(Book.dates[id] < Book.show_range.from || Book.dates[id] > Book.show_range.to) {
        $('#' + id).addClass('hidden');
      } else {
        $('#' + id).removeClass('hidden');
      }
    }
    Groupable.items_changed();
    var sum = 0;
    $('.filtered_flights > .foot .count .number').text($("#" + $.unique($(".flight").map(function(i,e) { return $(e).attr("id"); })).toArray().join(":first, #") + ":first").filter('.flight:not(.hidden)').each(function(i, e) {
      sum = sum + parseInt($(e).attr('data-duration'));
    }).length);
    $('.filtered_flights > .foot .sum .number').text(Format.duration(sum));
  },

  find_dates: function() {
    $(':not(.no).flight').each(function() { 
      var d = Parse.date_to_s($(this).attr('data-departure'));
      Book.dates[$(this).attr('id')] = d;
    });
  },

  init: function() {
    $('.hasDatepicker').datepicker("option", {
      onSelect: function(dateText, inst) {
        Book.update_flights(new Range($('#filter_from').datepicker("getDate"), $('#filter_to').datepicker("getDate")));
      }
    });
    Book.loaded_range = new Range($('#filter_from').datepicker("getDate"), $('#filter_to').datepicker("getDate"));
    Book.show_range = Book.loaded_range;
    Book.find_dates();
    Book.update_flights(Book.loaded_range);
  }
};

$(function() {
  if($('.filtered_flights').length > 0) {
    $('a.change_params').live('click', function() {
      var uri = parseUri(this.href);
      uri.params.group_by = Groupable.current_group;
      uri.params.filter = {};
      uri.params.filter.from_parse_date = Format.date_to_s(Book.show_range.from);
      uri.params.filter.to_parse_date = Format.date_to_s(Book.show_range.to);
      uri.params.ignore = $(".print_off").map(function(i, e) { return $(e).attr("id"); }).toArray();
      uri.params.aggregate_entries = $("#aggregate_entries").is(":checked") ? 1 : undefined;
      this.href = uri.reconstruct();
      //return false;
    });
    Groupable.init(function() {
      var sum = 0;
      this.find('.flight').each(function (i, e) {
        sum = sum + parseInt($(e).attr('data-duration'));
      });
      this.find('.foot .sum .number').text(Format.duration(sum));
    });
    $("#aggregate_entries").change(function() {
      Aggregate.check();
    });
    Book.init();
  }
});
