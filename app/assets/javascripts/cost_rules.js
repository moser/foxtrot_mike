var CostRules = {
  cost_rule_type: function(other_cost_category_parameter) {
    if(other_cost_category_parameter == 'plane_cost_category_id') {
      return 'flight_cost_rules';
    } else {
      return 'wire_launch_cost_rules';
    }
  },
  reload_cost_rules: function() {
    person_cost_category_id = $.bbq.getState("person_cost_category_id");
    other_cost_category_parameter = $.bbq.getState("other_cost_category_parameter");
    other_cost_category_id = $.bbq.getState("other_cost_category_id");
    
    $('a[data-parameter=person_cost_category_id]').parent().removeClass('current');
    $('a[data-parameter=person_cost_category_id][data-value=' + person_cost_category_id + ']').parent().addClass('current');

    $('a[data-parameter=plane_cost_category_id]').parent().removeClass('current');
    $('a[data-parameter=wire_launcher_cost_category_id]').parent().removeClass('current');
    $('a[data-parameter='+ other_cost_category_parameter +'][data-value=' + other_cost_category_id + ']').parent().addClass('current');

    var data = { person_cost_category_id: person_cost_category_id };
    data[other_cost_category_parameter] = other_cost_category_id;
    
    if(person_cost_category_id && other_cost_category_parameter && other_cost_category_id) {
      $.ajax({
              url: "/" + CostRules.cost_rule_type(other_cost_category_parameter),
              data: data, 
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
    var state = null;
    if($(e.target).attr('data-parameter') == 'person_cost_category_id') {
      state = { person_cost_category_id: $(e.target).attr('data-value') };
    } else {
      state = { other_cost_category_parameter: $(e.target).attr('data-parameter'),
                other_cost_category_id: $(e.target).attr('data-value') };
    }
    $.bbq.pushState(state);
    return false;
  },
  remote_form: function(e) {
    $.ajax({url: $('#new_flight_cost_rule').attr('action'),
      data: $('#new_flight_cost_rule').serialize(),
      type: 'POST',
      success: function(html, status, xhr) {
        jQuery(document).trigger('close.facebox');
        CostRules.reload_cost_rules();
      },
      error: function(xhr, status) {
        $('#facebox .content').html($(xhr.responseText));
        DomInsertionWatcher.notify_listeners($('#facebox .content'));
      }
    });
    return false;
  },
  navigate: function(e) {
    CostRules.reload_cost_rules();
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
    $('a.update_selection').live('click', CostRules.update);
    $('#new_flight_cost_rule').live('submit', CostRules.remote_form);
    person_cost_category_id = $('.person_cost_categories li.current a').attr('data-value');
    plane_cost_category_id = $('.plane_cost_categories li.current a').attr('data-value');
    wire_launcher_cost_category_id = $('.wire_launcher_cost_categories li.current a').attr('data-value');
    //cost_rule_type = $('.tablist li.current a').attr('data-value');
    $(window).bind('hashchange', CostRules.navigate);
    if(plane_cost_category_id) {
      $.bbq.pushState({ person_cost_category_id: person_cost_category_id,
                        other_cost_category_parameter: 'plane_cost_category_id',
                        other_cost_category_id: plane_cost_category_id });
    } else {
      $.bbq.pushState({ person_cost_category_id: person_cost_category_id,
                        other_cost_category_parameter: 'wire_launcher_cost_category_id',
                        other_cost_category_id: wire_launcher_cost_category_id });
    }
  }
};

$(function() {
  if($('.cost_rules').length > 0) {
    CostRules.init();
  }
});
