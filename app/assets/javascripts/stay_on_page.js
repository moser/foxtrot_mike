var StayOnPage = {
  load_list: function(url) {
    $.get(url, function(html) {
      $('.list').replaceWith($(html));
      DomInsertionWatcher.notify_listeners($('.list'));
      PleaseWait.vote_hide();
    });
    PleaseWait.vote_show();
  },
  replace: function(href) {
    $.get(href, function(html) {
      var item = $(html).hide();
      if($('.item').length == 0) {
        $('.list').before(item).hide();
      } else {
        $('.item').replaceWith(item);
        $('.list').hide();
      }
      DomInsertionWatcher.notify_listeners($('.item'));
      $('.item').find('form.sop').bind('submit', StayOnPage.submit);
      item.show();
      PleaseWait.vote_hide();
    });
    PleaseWait.vote_show();
  },
  submit: function(e) {
    var form = $(e.target);
    PleaseWait.vote_show(); //TODO remove when async again
    $.ajax({url: form.attr('action'),
          async: false, //TODO watch error http://forum.jquery.com/topic/problem-with-ajax-and-redirect-since-jquery-1-4-2
          data: form.serialize(),
          type: 'POST',
          success: function(html, status, xhr) {
            $('.item').replaceWith($(html));
            $('.list').hide();
            DomInsertionWatcher.notify_listeners($('.item'));
            $('.item').find('form.sop').bind('submit', StayOnPage.submit);
            PleaseWait.vote_hide();
          },
          error: function(xhr, status) {
            $('.item').replaceWith($(html));
            $('.list').hide();
            DomInsertionWatcher.notify_listeners($('.item'));
            $('.item').find('form.sop').bind('submit', StayOnPage.submit);
            PleaseWait.vote_hide();
          }
    });
    //PleaseWait.vote_show(); 
    return false;
  },
  click_replace: function(e) {
    $.bbq.pushState({ method: "replace", p: e.target.href });
    return false;
  },
  back: function(href) {
    var list = $('.list');
    if(list.length == 0) {
      $('.item').before($('<div class="list" />'));
      StayOnPage.load_list(href);
    } else {
      list.show();
    }
    $('.item').remove();
  },
  click_back : function(e) {
    $.bbq.pushState({ method: "back", p: e.target.href });
    return false;
  },
  goto_page: function(page) {
    var list = $('.list');
    if(list.length == 0) {
      $('.item').before($('<div class="list" />'));
    } else {
      list.show();
    }
    $('.item').remove();
    var current_page = $('.list .pagination em').text();
    var move_to_cache = function(q){
      if($('#cache #page-' + current_page).length == 0) {
        $('#cache').append($('<div id="page-'+ current_page +'" />'));
      }
      $('#cache #page-' + current_page).empty().append(q);
    }

    if($('#cache #page-' + page).length == 0) {
      $.get($('a.page[data-page=' + page + ']').attr('href'), function(html) {
        move_to_cache($('.list').contents());
        $('.list').replaceWith($(html));
        PleaseWait.vote_hide();
      });
      PleaseWait.vote_show();
    } else {
      move_to_cache($('.list').contents());
      $('.list').empty().append($('#cache #page-' + page).contents());
    }
  },
  click_goto_page: function(e) {
    $.bbq.pushState({ method: "goto_page", p: $(e.target).attr('data-page') });
    return false;
  },
  navigate: function() {
    if($.bbq.getState('method')) {
      StayOnPage[$.bbq.getState('method')]($.bbq.getState('p'));
    }
  },
  init: function() {
    StayOnPage.current_page = urlParams.page ? urlParams.page : '1';
    $('a.sop.show').live('click', StayOnPage.click_replace);
    $('a.sop.edit').live('click', StayOnPage.click_replace);
    $('a.sop.new').live('click', StayOnPage.click_replace);
    $('a.sop.back').live('click', StayOnPage.click_back);
    $('.pagination a.page').live('click', StayOnPage.click_goto_page);
    $('body').append($('<div id="cache" class="hidden" />'));
    if($('.pagination').length > 0) {
      $.bbq.pushState({ method: 'goto_page', p: (urlParams.page ? urlParams.page : '1') });
    } else {
      $.bbq.pushState({ method: 'back', p: '' });
    }
    $(window).bind('hashchange', StayOnPage.navigate);
  }
};

$(function() {
  StayOnPage.init();
});
