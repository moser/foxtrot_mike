var Parse = {
  time_pattern: /([0-9]+)(\.|:)([0-9]+)/,
  date_pattern_de: /([0-9]+)\.([0-9]+)\.([0-9]+)/,
  date_pattern_en: /([0-9]+)(-|\/)([0-9]+)(-|\/)([0-9]+)/,
  date_pattern_to_s: /([0-9]+)-([0-9]+)-([0-9]+)/,
  duration_pattern: /([0-9]+):([0-9]+)/,
  time: function(str) {
    matches = this.time_pattern.exec(str);
    if(matches != null && matches.length == 4) {
      return {h: this.integer(matches[1]), m: this.integer(matches[3]) };
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
    return obj;
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
    h = Math.floor(i / 60);
    m = i % 60;
    return h + ":" + (m < 10 ? "0": "") + m;
  },
  time: function(obj) {
    return obj.h + ":" + (obj.m < 10 ? "0": "") + obj.m;
  },
  time_of_date: function(date) {
    var h = date.getHours();
    var m = date.getMinutes();
    return ((h < 10 ? '0': '') + h) + ":" + (m < 10 ? "0": "") + m;
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
  $('a.facebox').live('click', function(e) { jQuery.facebox({ ajax: e.target.href }); return false; });
  $('body').ajaxError(function(e, xhr, o, exception) {
    if(xhr.status == 500) {
      jQuery.facebox("An error occurred. Please try reloading the page.");
    }
  });
  $('.hide_on_startup').hide();
  $('.show_on_startup').show();
  $('form.submit_when_changed').find('input').live('change', function() {
    var form = $(this).parents('form.submit_when_changed');
    form.submit();
  });

  $('a.print_pdf').live('click', function() {
    $.ajax({  url: '/pdfs', 
              type: 'POST', 
              data: { html: '<html>' + $('html').html() + '</html>' }, 
              success: function(data) {
                window.location.href = data + "?name=" + (window.location.pathname.slice(1).replace(/\//g, "-"));
              }
            });
    return false;
  });
});
