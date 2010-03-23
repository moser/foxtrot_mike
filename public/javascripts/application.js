// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Parse = {
  time_pattern: /([0-9]+)(\.|:)([0-9]+)/,
  date_pattern_de: /([0-9]+)\.([0-9]+)\.([0-9]+)/,
  date_pattern_en: /([0-9]+)(-|\/)([0-9]+)(-|\/)([0-9]+)/,
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
  duration: function(i) {
    h = Math.floor(i / 60);
    m = i % 60;
    return h + ":" + (m < 10 ? "0": "") + m;
  },
  time: function(obj) {
    return obj.h + ":" + (obj.m < 10 ? "0": "") + obj.m;
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
    this.element.append('<div class="disabler"><a href="#" class="stop_load">'+ I18n.t('stop') +'</a>');
    $('.stop_load', this.element).bind('click', {self: this}, function(e) {
      event.preventDefault();
      e.data.self.enable();
    });
  },
  enable: function() {
    $('.disabler', this.element).remove();
  }
};
