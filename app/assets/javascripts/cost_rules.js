var CostRules = {
  cost_rule_type: function(other_cost_category_parameter) {
    if(other_cost_category_parameter == 'plane_cost_category_id') {
      return 'flight_cost_rules';
    } else {
      return 'wire_launch_cost_rules';
    }
  },
  reload_cost_rules: function() {
    person_cost_category_id = window.History.getState().data.person_cost_category_id;
    other_cost_category_parameter = window.History.getState().data.other_cost_category_parameter;
    other_cost_category_id = window.History.getState().data.other_cost_category_id;

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
                $("#cost_rules").html(html);
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
    var state = window.History.getState().data;
    if($(e.target).attr('data-parameter') == 'person_cost_category_id') {
      state.person_cost_category_id = $(e.target).attr('data-value');
    } else {
      state.other_cost_category_parameter = $(e.target).attr('data-parameter');
      state.other_cost_category_id = $(e.target).attr('data-value');
    }
    CostRules.pushState(state);
    CostRules.reload_cost_rules();
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
    person_cost_category_id = $('.person_cost_categories li.current a').attr('data-value');
    plane_cost_category_id = $('.plane_cost_categories li.current a').attr('data-value');
    wire_launcher_cost_category_id = $('.wire_launcher_cost_categories li.current a').attr('data-value');
    //cost_rule_type = $('.tablist li.current a').attr('data-value');
    $(window).bind('popstate', CostRules.navigate);
    var state = null;
    if(plane_cost_category_id) {
      state = { person_cost_category_id: person_cost_category_id,
                other_cost_category_parameter: 'plane_cost_category_id',
                other_cost_category_id: plane_cost_category_id };
    } else {
      state = { person_cost_category_id: person_cost_category_id,
                other_cost_category_parameter: 'wire_launcher_cost_category_id',
                other_cost_category_id: wire_launcher_cost_category_id };
    }
    CostRules.pushState(state);
  },
  pushState: function(state) {
    var params = { person_cost_category_id: state.person_cost_category_id };
    params[state.other_cost_category_parameter] = state.other_cost_category_id;
    window.History.pushState(state, window.document.title, "?" + $.param(params));
  }
};

$(function() {
  if($('.cost_rules').length > 0) {
    CostRules.init();
  }
});
