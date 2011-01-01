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
    if(Groupable.current_group != null) {
      $('.duplicate').remove();
      $('.duplicated').removeClass('duplicated');
      $('.group_container').append($('.groupable')).find('.group').remove();
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
        var group_div = $('#group-prototype .group').clone();
        var div = group_div.find('.items');
        var groupables = $(':not(.hidden).groupable[data-' + group_by + '*=(' + group + ')]');
        group_div.find('.foot .count .number').text(groupables.length);
        group_div.find('.head .title').text(h[group].title);
        group_div.find('.head .hint').text(h[group].line);
        groupables.each(function (i, e) {
          if($(e).parents('.group').length > 0) {
            var id = $(e).attr('id');
            div.append($(e).addClass('duplicated').clone().removeClass('duplicated').addClass('duplicate'));
          } else {
            div.append(e);
          }
        });
        div.find('.groupable').sortElements(function(a, b) { return parseInt($(a).attr('data-sort')) > parseInt($(b).attr('data-sort')) ? 1 : -1; });
        if(Groupable.group_callback) { Groupable.group_callback.call(group_div); }
        $('.group_container').append(group_div);
      }
    } else {
      $('.group_container').find('.groupable').sortElements(function(a, b) { return parseInt($(a).attr('data-sort')) > parseInt($(b).attr('data-sort')) ? 1 : -1; });
    }
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
//  last_group_id: 0,
//  collapsed: {},
  
//  is_collapsed: function(group_id) {
//    if(this.collapsed[group_id] == null) { this.collapsed[group_id] = true; }
//    return this.collapsed[group_id];
//  },
//  
//  next_group_id: function() {
//    Book.last_group_id++;
//    return '' + Book.last_group_id;
//  },
//  
//  ungroup: function(e) {
//    var old_id = $(e.target).parents('.flight').attr('data-group-id');
//    $(e.target).parents('.flight').attr('data-group-id', 'none');
//    var new_ids = [ Book.next_group_id(), Book.next_group_id() ]
//    $(e.target).parents('.flight').prevAll('.flight').attr('data-group-id', new_ids[0]);
//    $(e.target).parents('.flight').nextAll('.flight').attr('data-group-id', new_ids[1]);
//    Book.collapsed[new_ids[0]] = Book.collapsed[old_id];
//    Book.collapsed[new_ids[1]] = Book.collapsed[old_id];
//    Book.update_groups();
//    return false;
//  },
  
//  group: function(e) {    
//    var parent = $(e.target).parents('.group');
//    if(parent.length == 0) {
//      var flight = $(e.target).parents('.flight')[e.data]('.flight:not(.hidden)');      
//      if(flight.length == 1) {
//        var id = flight.attr('data-group-id'); id = (id == 'none' ? Book.next_group_id() : id);
//        $(e.target).parents('.flight').attr('data-group-id', id);
//        flight.attr('data-group-id', id);
//      } else {
//        var group = $(e.target).parents('.flight')[e.data]('.group').first();
//        if(group.length == 1) {          
//          $(e.target).parents('.flight').attr('data-group-id', group.attr('id'));
//        }
//      }
//      Book.update_groups();
//    }
//    return false;
//  },

//  update_groups: function() {
//    $('span.time').removeClass('marked');  
//    
//    $('.group').each(function(i, e) {
//      $(e).before($(e).find('.flight').removeClass('hide_when_collapsed')).remove();
//    });
//    
//    var visited = { none: true };
//    $('.flight:not(.hidden)').map(function(i, e) { 
//      return $(e).attr("data-group-id"); 
//    }).each(function(i, e) {
//      if(!visited[e]) {
//        visited[e] = true;
//        var el = $('.flight[data-group-id=' + e + ']:not(.hidden)')
//        if(el.length > 1) {
//          el.wrapAll('<div class="group '+ (Book.is_collapsed(e) ? 'collapsed' : '') +'" id="'+ e +'" />');
//        }
//      }
//    });
//    
//    $('.group').each(function(i, e) {    
//      var n = $(e).find('.flight').length;
//      var sum = 0;
//      $(e).find('.flight').each(function(i, e) {
//        sum = sum + parseInt($(e).attr('data-duration'));
//        if(i == 0) {
//          $(e).removeClass('hide_when_collapsed').children('.time:eq(0)').addClass('marked');
//        } else if(i == n - 1) {
//          $(e).removeClass('hide_when_collapsed').children('.time:eq(1)').addClass('marked');
//        } else {
//          if(i == 1) {
//            $(e).before('<a href="#" class="toggle_collapsed"></a>');
//          }
//          $(e).addClass('hide_when_collapsed');
//        }
//      });
//      $(e).append('<div class="sum"><span class="duration">' + Format.duration(sum) + '</span></div>');        
//    });
//  },

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
    $('.content > .foot .count .number').text($('.flight:not(.hidden):not(.duplicate)').each(function(i, e) {
      sum = sum + parseInt($(e).attr('data-duration'));
    }).length);
    $('.content > .foot .sum .number').text(Format.duration(sum));
//    Book.update_groups();
  },

  find_dates: function() {
    $(':not(.no).flight').each(function() { 
      var d = Parse.date_to_s($(this).attr('data-departure'));
      Book.dates[$(this).attr('id')] = d;
    });
  },
  
//  toggle_collapsed: function(e) {
//    var group_id = $(e.target).parent('.group').toggleClass('collapsed').attr('id');
//    Book.collapsed[group_id] = !Book.collapsed[group_id];
//    return false;
//  },

  init: function() {
//    $('a.group_up').live('click', 'prev', Book.group);
//    $('a.group_down').live('click', 'next', Book.group);
//    $('a.ungroup').live('click', Book.ungroup);
//    $('a.toggle_collapsed').live('click', Book.toggle_collapsed);
    $('.hasDatepicker').datepicker("option", {
      onSelect: function(dateText, inst) {
        Book.update_flights(new Range($('#filter_from').datepicker("getDate"), $('#filter_to').datepicker("getDate")));
      }
    });
    Book.loaded_range = new Range($('#filter_from').datepicker("getDate"), $('#filter_to').datepicker("getDate"));
    Book.show_range = Book.loaded_range;
    Book.find_dates();
    Book.update_flights(Book.loaded_range);
//    Book.update_groups();
  }
};

$(function() {
  Groupable.init(function() {
    var sum = 0;
    this.find('.flight').each(function (i, e) {
      sum = sum + parseInt($(e).attr('data-duration'));
    });
    this.find('.foot .sum .number').text(Format.duration(sum));
  });
  Book.init();
});
