function findVals(el) {
    var d = { blank: false }
    $(el).find('select').each(function(i, e) {
      matches = /_(\di)$/.exec($(e).attr('id'));
      if(matches != null) {
        d[matches[1]] = $(e).val();
        d.blank = d.blank || $(e).val() == '';
      }
    });
    return d;
}

function orig(el, type) {
  var d = findVals(el);
  if(d.blank) { return ''; }
  if(type == 'datetime') {
    return Format.date_time_short(new Date(d['1i'], d['2i'] - 1, d['3i'], d['4i'], d['5i'], 0));
  } else if(type == 'time') {
    return Format.time_of_date(new Date(2000, 0, 1, d['4i'], d['5i'], 0));
  } else if(type == 'date') {
    return Format.date_short(new Date(d['1i'], d['2i'] - 1, d['3i'], 0, 0, 0));
  }
}

function replacePickers(q, type) {
  q.find('div.input.'+ type +':not(.replaced)').each(function(i,e) {
    e = $(e);
    var label = e.children('label');
    var spans = e.children('span');
    var orig_name = e.children('select').first().attr('name');
    var model_name = orig_name.split("[")[0];
    var attribute = orig_name.split("[")[1].replace(/\(.*\)\]$/, '');
    var d = $('<input id="'+ model_name + '_'+ attribute +'" name="'+ model_name + '['+ attribute +'_parse_'+ type +']"/>');
    d.val(orig(e, type));
    e.empty().append(label).append(d).append(spans).addClass('replaced');
    d[type + 'picker']({constrainInput: false, dateFormat: "dd.mm.yy"});
  });
  return q;
}

function replaceAllAndAttachPickers(q) {
  replacePickers(q, 'datetime');
  replacePickers(q, 'date');
  replacePickers(q, 'time');
  q.find('.datetimepicker').datetimepicker();
  q.find('.timepicker').timepicker();
  q.find('.datepicker').datepicker();
}

$(function () {
  replaceAllAndAttachPickers($('body'));
  DomInsertionWatcher.register(function () { replaceAllAndAttachPickers(this); } );
});
