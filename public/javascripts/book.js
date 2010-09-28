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
    if(this.from < other.from) { result.lower = new Range(this.from, other.from); }
    if(this.to > other.to) { result.upper = new Range(other.to, this.to); }
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

var Book = {
  dates: {},
  loaded_range: null,
  last_group_id: 0,
  collapsed: {},
  
  is_collapsed: function(group_id) {
    if(this.collapsed[group_id] == null) { this.collapsed[group_id] = true; }
    return this.collapsed[group_id];
  },
  
  next_group_id: function() {
    Book.last_group_id++;
    return '' + Book.last_group_id;
  },
  
  ungroup: function(e) {
    var old_id = $(e.target).parents('.flight').attr('data-group-id');
    $(e.target).parents('.flight').attr('data-group-id', 'none');
    var new_ids = [ Book.next_group_id(), Book.next_group_id() ]
    $(e.target).parents('.flight').prevAll('.flight').attr('data-group-id', new_ids[0]);
    $(e.target).parents('.flight').nextAll('.flight').attr('data-group-id', new_ids[1]);
    Book.collapsed[new_ids[0]] = Book.collapsed[old_id];
    Book.collapsed[new_ids[1]] = Book.collapsed[old_id];
    Book.update_groups();
    return false;
  },

  group: function(e) {    
    var parent = $(e.target).parents('.group');
    if(parent.length == 0) {
      var flight = $(e.target).parents('.flight')[e.data]('.flight:not(.hidden)');      
      if(flight.length == 1) {
        var id = flight.attr('data-group-id'); id = (id == 'none' ? Book.next_group_id() : id);
        $(e.target).parents('.flight').attr('data-group-id', id);
        flight.attr('data-group-id', id);
      } else {
        var group = $(e.target).parents('.flight')[e.data]('.group').first();
        if(group.length == 1) {          
          $(e.target).parents('.flight').attr('data-group-id', group.attr('id'));
        }
      }
      Book.update_groups();
    }
    return false;
  },

  update_groups: function() {
    $('span.time').removeClass('marked');  
    
    $('.group').each(function(i, e) {
      $(e).before($(e).find('.flight').removeClass('hide_when_collapsed')).remove();
    });
    
    var visited = { none: true };
    $('.flight:not(.hidden)').map(function(i, e) { 
      return $(e).attr("data-group-id"); 
    }).each(function(i, e) {
      if(!visited[e]) {
        visited[e] = true;
        var el = $('.flight[data-group-id=' + e + ']:not(.hidden)')
        if(el.length > 1) {
          el.wrapAll('<div class="group '+ (Book.is_collapsed(e) ? 'collapsed' : '') +'" id="'+ e +'" />');
        }
      }
    });
    
    $('.group').each(function(i, e) {    
      var n = $(e).find('.flight').length;
      var sum = 0;
      $(e).find('.flight').each(function(i, e) {
        sum = sum + parseInt($(e).attr('data-duration'));
        if(i == 0) {
          $(e).removeClass('hide_when_collapsed').children('.time:eq(0)').addClass('marked');
        } else if(i == n - 1) {
          $(e).removeClass('hide_when_collapsed').children('.time:eq(1)').addClass('marked');
        } else {
          if(i == 1) {
            $(e).before('<a href="#" class="toggle_collapsed"></a>');
          }
          $(e).addClass('hide_when_collapsed');
        }
      });
      $(e).append('<div class="sum"><span class="duration">' + Format.duration(sum) + '</span></div>');        
    });
  },

  update_flights: function(range, old_range) {    
    if(Book.loaded_range.lt(range)) {
      var diff = range.minus(Book.loaded_range);
      if(diff.lower) { Book.load_and_show_flights(diff.lower, 'prepend'); }
      if(diff.upper) { Book.load_and_show_flights(diff.upper, 'append'); }
    } else {
      Book.show_range = range;
      Book.hide_flights();
    }
  },

  load_and_show_flights: function(range, insert_method) {
    $.get($('.base_url').text() + '/flights',
          { from: Format.date_to_s(range.from),
            to: Format.date_to_s(range.to) },
          function(html) {
            $('.flights')[insert_method]($(html));
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
      if(Book.dates[id] <= Book.show_range.from || Book.dates[id] > Book.show_range.to) {
        $('#' + id).addClass('hidden');
      } else {
        $('#' + id).removeClass('hidden');
      }
    }
    Book.update_groups();
  },

  find_dates: function() {
    $(':not(.no).flight').each(function() { 
      var d = Parse.date_to_s($(this).attr('data-departure'));
      Book.dates[$(this).attr('id')] = d;
    });
  },
  
  toggle_collapsed: function(e) {
    var group_id = $(e.target).parent('.group').toggleClass('collapsed').attr('id');
    Book.collapsed[group_id] = !Book.collapsed[group_id];
    return false;
  },

  init: function(tl) {
    $('a.group_up').live('click', 'prev', Book.group);
    $('a.group_down').live('click', 'next', Book.group);
    $('a.ungroup').live('click', Book.ungroup);
    $('a.toggle_collapsed').live('click', Book.toggle_collapsed);
    tl.register(Book.update_flights);    
    Book.loaded_range = new Range(Parse.date_to_s($('.book .from').text()), Parse.date_to_s($('.book .to').text()));
    Book.show_range = Book.loaded_range;
    Book.find_dates();
    Book.update_flights(tl.range, null);
    Book.update_groups();
  }
};

var Timeline = {
  set_date: function(e) {    
    var old_range = Timeline.range;
    var nu = new Range(old_range.from, old_range.to);
    nu[e.data] = Parse.date_to_s($(e.target).attr('data-date'));    
    //sanitize range
    if(nu.from == nu.to) {      
      return false;
    }

    Timeline.push_state({ from: nu.from, to: nu.to });
    return false;
  },
  
  set_base: function(e) {    
    Timeline.push_state({ base: $(e.target).attr('data-date') });    
    return false;
  },
  
  set_scope: function(e) {    
    Timeline.push_state({ scope: $(e.target).attr('data-scope') });
    return false;
  },
  
  reload: function() {
    $.get($('.base_url').text() + '/timeline', 
          { from: Format.date_to_s(Timeline.range.from),
            to: Format.date_to_s(Timeline.range.to),
            base: Timeline.base,
            scope: Timeline.scope },
            function(html) { 
              $('.timeline').replaceWith($(html));
              var data = Timeline.load_data_from_dom();
              Timeline.push_state(data);
            });
  },

  init: function() {
    $('a.set_date.from').live('click', 'from', Timeline.set_date);
    $('a.set_date.to').live('click', 'to', Timeline.set_date);
    $('a.set_base').live('click', Timeline.set_base);
    $('a.set_scope').live('click', Timeline.set_scope);    
    $(window).bind('hashchange', Timeline.navigate); 
    $(window).trigger('hashchange');
    if(!this.range && !this.base && !this.scope) {
      var data = this.load_data_from_dom();
      Timeline.range = new Range(data.from, data.to);
      Timeline.base = data.base;
      Timeline.scope = data.scope;
      this.push_state({});
    }
  },
  
  load_data_from_dom: function() {
    return { from: Parse.date_to_s($('a.set_date.from.active').attr('data-date')),
             to: Parse.date_to_s($('a.set_date.to.active').attr('data-date')),
             base: $('.base').text(),
             scope: $('.scope').text() };
  },
  
  push_state: function(obj) {
    var state = { from: Timeline.range.from, 
                  to: Timeline.range.to,
                  base: Timeline.base,
                  scope: Timeline.scope };                
    for(var k in obj) {
      state[k] = obj[k];
    }
    state.from = Format.date_to_s(state.from);
    state.to = Format.date_to_s(state.to);
    var push = false;
    for(var k in state) {
      push = push || state[k] != $.bbq.getState(k);      
    }
    if(push) {      
      $.bbq.pushState(state);
    }
  },

  register: function(f) {
    if(Timeline.listeners == null) { Timeline.listeners = []; }
    Timeline.listeners.push(f);
  },

  notify_listeners: function(range, old_range) {
    if(Timeline.listeners == null) { Timeline.listeners = []; }
    Timeline.listeners.forEach(function(f) { f.call(null, range, old_range); });
  },

  navigate: function(e) {
    var first_time = !$.bbq.getState("from") && !$.bbq.getState("to") && 
                     !$.bbq.getState("base") && !$.bbq.getState("scope");                
    if(!first_time) {      
      var old_range = Timeline.range;
      var reload = (Timeline.base != $.bbq.getState("base") || Timeline.scope != $.bbq.getState("scope"));   
      Timeline.range = new Range(Parse.date_to_s($.bbq.getState("from")), Parse.date_to_s($.bbq.getState("to")));
      Timeline.base = $.bbq.getState("base");
      Timeline.scope = $.bbq.getState("scope");      
      $('a.set_date.active').removeClass('active');
      $('a.set_date.from[data-date='+ Format.date_to_s(Timeline.range.from) + ']').addClass('active');
      $('a.set_date.to[data-date='+ Format.date_to_s(Timeline.range.to) + ']').addClass('active');
      Timeline.notify_listeners(Timeline.range, old_range);
      if(reload) {
        Timeline.reload();
      }
    } else {
      
    }
  }
};

$(function() {
  Timeline.init();
  Book.init(Timeline);
});
