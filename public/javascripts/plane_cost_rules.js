var PlaneCostRules = {
 reload_cost_rules: function() {
    plane_cost_category_id = $.bbq.getState("plane_cost_category_id");
    person_cost_category_id = $.bbq.getState("person_cost_category_id");
    cost_rule_type = $.bbq.getState("cost_rule_type");
    var state = { plane_cost_category_id: plane_cost_category_id, 
                   person_cost_category_id: person_cost_category_id,
                   cost_rule_type: cost_rule_type };
    
    for(var k in state) {
      $('a[data-parameter=' + k + ']').parent().removeClass('current');
      $('a[data-parameter=' + k + '][data-value=' + state[k] + ']').parent().addClass('current');
    }
    
    if(plane_cost_category_id && person_cost_category_id && cost_rule_type) {
      $.ajax({
              url: "/" + cost_rule_type,
              data: {plane_cost_category_id: plane_cost_category_id,
                      person_cost_category_id: person_cost_category_id}, 
              success: function(html) {
                $('#cost_rules').html(html);
                DomInsertionWatcher.notify_listeners($('#cost_rules'));
                
                PleaseWait.vote_hide();
              },
              error: function(xhr) {
                $('#cost_rules').html(xhr.responseText);
                PleaseWait.vote_hide();
              }
      });
      PleaseWait.vote_show();  
    }
  },
  update: function(e) {
    person_cost_category_id = $('.person_cost_categories li.current a').attr('data-value');
    plane_cost_category_id = $('.plane_cost_categories li.current a').attr('data-value');
    cost_rule_type = $('.tablist li.current a').attr('data-value');

    var state = { plane_cost_category_id: plane_cost_category_id, 
                   person_cost_category_id: person_cost_category_id,
                   cost_rule_type: cost_rule_type };

    state[$(e.target).attr('data-parameter')] = $(e.target).attr('data-value')
    $.bbq.pushState(state);
    return false;
  },
  remote_form: function(e) {
    $.ajax({url: $('#new_time_cost_rule').attr('action'),
      data: $('#new_time_cost_rule').serialize(),
      type: 'POST',
      success: function(html, status, xhr) {
        jQuery(document).trigger('close.facebox');
        PlaneCostRules.reload_cost_rules();
      },
      error: function(xhr, status) {
        $('#facebox .content').html($(xhr.responseText));
        DomInsertionWatcher.notify_listeners($('#facebox .content'));
      }
    });
    return false;
  },
  navigate: function(e) {
    PlaneCostRules.reload_cost_rules();
  },
  init: function() {
    $('a.new').live('click', function(e) {
      $.facebox(function() {
        $.get(e.target.href, function(html) {
          $.facebox($(html));
          DomInsertionWatcher.notify_listeners($('body'));
        });
      });
      return false;
    });
    $('a.update_selection').live('click', PlaneCostRules.update);
    $('#new_time_cost_rule').live('submit', PlaneCostRules.remote_form);
    person_cost_category_id = $('.person_cost_categories li.current a').attr('data-value');
    plane_cost_category_id = $('.plane_cost_categories li.current a').attr('data-value');
    cost_rule_type = $('.tablist li.current a').attr('data-value');
    $(window).bind('hashchange', PlaneCostRules.navigate);
    $.bbq.pushState({ cost_rule_type: cost_rule_type, 
                      person_cost_category_id: person_cost_category_id,
                      plane_cost_category_id: plane_cost_category_id });
  }
};

$(function() {
  PlaneCostRules.init();
});
