var Parse = {
  time_pattern: /([0-9]{1,2})(\.|:){0,1}([0-9]{2})/,
  date_pattern_de: /([0-9]+)\.([0-9]+)\.([0-9]+)/,
  date_pattern_en: /([0-9]+)(-|\/)([0-9]+)(-|\/)([0-9]+)/,
  date_pattern_to_s: /([0-9]+)-([0-9]+)-([0-9]+)/,
  duration_pattern: /([0-9]+):([0-9]+)/,
  time: function(str) {
    matches = this.time_pattern.exec(str);
    if(matches != null && matches.length == 4) {
      return {h: this.integer(matches[1]) % 24, m: this.integer(matches[3]) % 60 };
    } else {
      return false;
    }
  },
  date: function(str) {
    matches = this.date_pattern_de.exec(str);
    if(matches != null && matches.length == 4) {
      obj = {m: this.integer(matches[2]), d: this.integer(matches[1]), y: this.integer(matches[3]) };
    } else {
      matches = this.date_pattern_en.exec(str);
      if(matches != null && matches.length == 6) {
        obj = {m: this.integer(matches[1]), d: this.integer(matches[3]), y: this.integer(matches[5]) };
      } else {
        return false;
      }
    }
    if(obj.y < 100) {
      obj.y += obj.y > 50 ? 1900 : 2000;
    }
    return new Date(obj.y, obj.m - 1, obj.d);;
  },
  date_to_s: function(str) {
    matches = this.date_pattern_to_s.exec(str);
    if(matches != null && matches.length == 4) {
      return new Date(this.integer(matches[1]), this.integer(matches[2]) - 1, this.integer(matches[3]));
    } else {
      return false;
    }
  },
  duration: function(str) {
    matches = this.duration_pattern.exec(str);
    if(matches != null && matches.length == 3) {
      return this.integer(matches[1]) * 60 + this.integer(matches[2]);
    } else {
      return false;
    }
  },
  integer: function(str) {
    str = this.dezero(str);
    return parseInt(str);
  },
  dezero: function(str) {
    if(/0[0-9]+/.test(str)) {
      str = str.replace(/^0+/, '');
      if(str.length == 0) {
        str = "0";
      }
    }
    return str;
  }
};

var Format = {
  date_to_s: function(date) {
    var m = date.getMonth() + 1;
    var d = date.getDate();
    return date.getFullYear() + '-' +  (m < 10 ? '0': '') + m + '-' + (d < 10 ? '0': '') + d;
  },
  date_time_short: function(date) {
    var m = date.getMonth() + 1;
    var d = date.getDate();
    var min = date.getMinutes();
    var h = date.getHours();
    return ((d < 10 ? '0': '') + d) + '.' + ((m < 10 ? '0': '') + m) + '.' +
            date.getFullYear() + ' ' + ((h < 10 ? '0': '') + h) + ':' + ((min < 10 ? '0': '') + min);
  },
  date_short: function(date) {
    var m = date.getMonth() + 1;
    var d = date.getDate();
    return ((d < 10 ? '0': '') + d) + '.' + ((m < 10 ? '0': '') + m) + '.' + date.getFullYear();
  },
  duration: function(i) {
    i = i % 1440;
    if(i < 0)
      i = 1440 + i;
    h = Math.floor(i / 60);
    m = i % 60;
    return h + ":" + (m < 10 ? "0": "") + m;
  },
  time: function(obj) {
    if(obj.h == undefined || obj.m == undefined) {
      return "--:--"
    }
    return (obj.h < 10 ? "0" : "") + obj.h + ":" + (obj.m < 10 ? "0": "") + obj.m;
  },
  time_of_date: function(date) {
    var obj = {h: date.getHours(), m: date.getMinutes()};
    return Format.time(obj);
  }
};

var Time = {
  add: function(time, minutes) {
    return {h: (time.h + Math.floor((time.m + minutes) / 60)) % 24, m: (time.m + minutes) % 60 };
  }
};

var UI = {};
UI.Disabler = function(el) {
  this.element = $(el);
};
UI.Disabler.prototype = {
  disable: function() {
    this.element.append('<div class="disabler"/>');
  },
  enable: function() {
    $('.disabler', this.element).remove();
  }
};

// parseUri 1.2.2
// (c) Steven Levithan <stevenlevithan.com>
// MIT License

function parseUri(str) {
	var	o   = parseUri.options,
		m   = o.parser[o.strictMode ? "strict" : "loose"].exec(str),
		uri = {},
		i   = 14;

	while (i--) uri[o.key[i]] = m[i] || "";

	uri[o.q.name] = {};
	uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
		if ($1) uri[o.q.name][$1] = $2;
	});
	
	
	uri.params = {}
	uri.query.split("&").forEach(function(e, i) {
	  if(/=/.exec(e)) {
	    s = e.split("=");
	    var value = s[1];
	    r = /^([a-zA-z0-9_\-]+)\[([\[\]a-zA-z0-9_\-]+)\]$/;
	    var f = function(str, to) {
	      m = r.exec(str);
	      if(m) {
	        if(!to[m[1]]) { to[m[1]] = {}; }
          f(m[2], to[m[1]]);
	      } else {
	        to[str] = value;
	      }
	    }
	    f(s[0], uri.params);
	  } else {
	    uri.params[e] = true;
	  }
	});
	
	uri.reconstruct = function() {
	  return this.protocol + "://" + this.authority + this.path + "?" + decodeURIComponent($.param(this.params));
	};

	return uri;
};

parseUri.options = {
	strictMode: false,
	key: ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"],
	q:   {
		name:   "queryKey",
		parser: /(?:^|&)([^&=]*)=?([^&]*)/g
	},
	parser: {
		strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
		loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
	}
};

// --parseUri 1.2.2

var PleaseWait = {
  n: 0,
  modal_n: 0,
  disabler: function() {
    if(!this.da) {
      this.da = new UI.Disabler(".content");
    }
    return this.da;
  },
  vote_show: function() {
    this.n++;
    $('.please_wait').show();
  },
  vote_hide: function() {
    this.n--;
    if(this.n < 0) { this.n = 0; }
    if(this.n == 0) { $('.please_wait').hide(); }
  },
  vote_modal_show: function() {
    this.modal_n++;
    this.disabler().disable();
  },
  vote_modal_hide: function() {
    this.modal_n--;
    if(this.modal_n < 0) { this.modal_n = 0; }
    if(this.modal_n == 0) { this.disabler().enable(); }
  }
};

var DomInsertionWatcher = {
  register: function(f) {
    if(DomInsertionWatcher.listeners == null) { DomInsertionWatcher.listeners = []; }
    DomInsertionWatcher.listeners.push(f);
  },
  notify_listeners: function(new_items) {
    if(new_items == null) { new_items = 'body'; }
    if(DomInsertionWatcher.listeners == null) { DomInsertionWatcher.listeners = []; }
    DomInsertionWatcher.listeners.forEach(function(f) { f.call($(new_items)); });
  }
};

var urlParams = {};
(function () {
    var e,
        d = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); },
        q = window.location.search.substring(1),
        r = /([^&=]+)=?([^&]*)/g;

    while (e = r.exec(q))
       urlParams[d(e[1])] = d(e[2]);
})();

jQuery.fn.sortElements = (function(){
    var sort = Array.prototype.sort;
    return function(comparator, getSortable) {
        getSortable = getSortable || function(){return this;};
        var placements = this.map(function(){
            var sortElement = getSortable.call(this),
                parentNode = sortElement.parentNode,
                // Since the element itself will change position, we have
                // to have some way of storing its original position in
                // the DOM. The easiest way is to have a 'flag' node:
                nextSibling = parentNode.insertBefore(
                    document.createTextNode(''),
                    sortElement.nextSibling
                );
            return function() {
                if (parentNode === this) {
                    throw new Error(
                        "You can't sort elements if any one is a descendant of another."
                    );
                }
                // Insert before flag:
                parentNode.insertBefore(this, nextSibling);
                // Remove flag:
                parentNode.removeChild(nextSibling);
            };
        });
        return sort.call(this, comparator).each(function(i){
            placements[i].call(getSortable.call(this));
        });
    };
})();

$(function() {
  $('a.facebox').live('click', function(e) {
    if(!e.ctrlKey && !e.shiftKey) {
      jQuery.facebox({ ajax: e.target.href }); 
      return false;
    }
  });
  $('body').ajaxError(function(e, xhr, o, exception) {
    if(xhr.status == 500) {
      jQuery.facebox("An error occurred. Please try reloading the page.");
      PleaseWait.vote_hide();
    }
  });
  $('.hide_on_startup').hide();
  $('.show_on_startup').show();
  DomInsertionWatcher.register(function() {
    $('.hide_on_startup').hide();
    $('.show_on_startup').show();
  });
  $('form.submit_when_changed').find('input').live('change', function() {
    var form = $(this).parents('form.submit_when_changed');
    form.submit();
  });
});
