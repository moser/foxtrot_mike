var IF = {
  insert: function(h, target, link) {
    h.find('a.inline_form_hide').bind('click', function(e) {
      target.show();
      h.remove();
      return false;
    }).end().find('form').bind('submit', function(e) {
      var form = $(e.target);
      PleaseWait.vote_show(); //TODO remove when async again
      $.ajax({url: form.attr('action'),
            async: false, //TODO watch error http://forum.jquery.com/topic/problem-with-ajax-and-redirect-since-jquery-1-4-2
            data: form.serialize(),
            type: 'POST',
            success: function(html, status, xhr) {
              $.get($(link).attr('data-replace'), function(html) {
                target.closest('.inline_form_replace_context').replaceWith(html);
                DomInsertionWatcher.notify_listeners($('.inline_form_replace_context'));
                PleaseWait.vote_hide();
              });
            },
            error: function(xhr, status) {
              h.html($(xhr.responseText));
              IF.insert(h, target, link);
              DomInsertionWatcher.notify_listeners(h);
              PleaseWait.vote_hide();
              return false;
            }
      });
      //PleaseWait.vote_show(); //TODO uncomment when async again
      return false;
    });
  },
  load: function(e) {   
    var target = $(e.target);
    if($(target).parents('.inline_form_hide_context').length > 0) {
      target = $(target).closest('.inline_form_hide_context');
    }
    $.get(e.target.href, function(html) {
      var h = $('<div class="inline_form">' + html + '</div>');
      target.before(h);
      IF.insert(h, target, e.target);
      target.hide();
      
      DomInsertionWatcher.notify_listeners(h);
      PleaseWait.vote_hide();
    });
    PleaseWait.vote_show();
    return false;
  },
  button_to: function(e) {
      var form = $(e.target);
      PleaseWait.vote_show(); //TODO remove when async again
      $.ajax({url: form.attr('action'),
            async: false, //TODO watch error http://forum.jquery.com/topic/problem-with-ajax-and-redirect-since-jquery-1-4-2
            data: form.serialize(),
            type: 'POST',
            success: function(html, status, xhr) {
              $.get(form.find("input[type=submit]").attr('data-replace'), function(html) {
                form.closest('.inline_form_replace_context').replaceWith(html);
                DomInsertionWatcher.notify_listeners($('.inline_form_replace_context'));
                PleaseWait.vote_hide();
              });
            }
      });
      //PleaseWait.vote_show(); //TODO uncomment when async again
      return false;
  },
  init: function() {
    $('a.inline_form_show').live('click', IF.load);
    $('form.button_to').live('submit', IF.button_to);
  }
};

$(function() {
  IF.init();
});