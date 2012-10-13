var DateTimePickers = {

  findVals: function(el) {
      var d = { blank: false }
      $(el).find('select').each(function(i, e) {
        matches = /_(\di)$/.exec($(e).attr('id'));
        if(matches != null) {
          d[matches[1]] = $(e).val();
          d.blank = d.blank || $(e).val() == '';
        }
      });
      return d;
  },

  orig: function(el, type) {
    var d = DateTimePickers.findVals(el);
    if(d.blank) { return ''; }
    if(type == 'datetime') {
      return Format.date_time_short(new Date(d['1i'], d['2i'] - 1, d['3i'], d['4i'], d['5i'], 0));
    }
  },
  
  replace: function(i,e, type) {
    e = $(e);
    var label = e.children('label');
    var spans = e.children('span');
    var orig_name = e.children('select').first().attr('name');
    var model_name = orig_name.split("[")[0];
    var attribute = orig_name.split("[")[1].replace(/\(.*\)\]$/, '');
    var d = $('<input id="'+ model_name + '_'+ attribute +'" name="'+ model_name + '['+ attribute +'_parse_'+ type +']"/>');
    d.val(DateTimePickers.orig(e, type));
    e.empty().append(label).append(d).append(spans).addClass('replaced');
    if(e.hasClass("disabled")) {
      e.children("input").attr("disabled", "disabled")
    }
    return $(d);
  },
  
  replaceAndAttachPickersManually: function(q, type, f) {
    return q.map(function(i, e) { 
      return f(DateTimePickers.replace(i, e, type));
    });
  },

  replacePickers: function(q, type) {
    q.find('div.input.'+ type +':not(.replaced):not(.no_replace)').each(function(i, e) { 
      DateTimePickers.replace(i, e, type)[type + 'picker']({constrainInput: false, dateFormat: "dd.mm.yy"});
    });
    return q;
  },

  replaceAllAndAttachPickers: function(q) {
    DateTimePickers.replacePickers(q, 'date');
    q.find('.datepicker').datepicker();
  }
}

$(function () {
  DateTimePickers.replaceAllAndAttachPickers($('body'));
  DomInsertionWatcher.register(function () { DateTimePickers.replaceAllAndAttachPickers(this); } );
});
