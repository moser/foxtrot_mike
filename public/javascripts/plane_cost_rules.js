//TODO OOP it

var plane_cost_category_id = null;
var person_cost_category_id = null;
var cost_rule_type = null;
var plane_cost_category_element = null;
var person_cost_category_element = null;
var cost_rule_type_element = null;

function reload_cost_rules() {
  if(plane_cost_category_id && person_cost_category_id && cost_rule_type) {
    $.get("http://localhost:3000/" + cost_rule_type,
          {plane_cost_category_id: plane_cost_category_id,
           person_cost_category_id: person_cost_category_id}, 
          function(html) {
      $('#cost_rules').html(html);
      $('.controls').hide(); //TODO
      $('.cost_rule').bind('mouseenter', function(e) {
        $('.controls', $(e.target)).show();
      });
      $('.cost_rule').bind('mouseleave', function(e) {
        $('.controls', $(e.target)).hide();
      });
    });    
  }
}

function update_selection(e) {
  var str = e.target.href.split('#').pop();
  if(str) {
    var keyval = str.split('=');
    if(keyval.length == 2) {
      if(keyval[0] == 'person_cost_category') {
        person_cost_category_id = keyval[1];
        if(person_cost_category_element) {
          $(person_cost_category_element).removeClass('marked');
        }
        person_cost_category_element = e.target;
        $(person_cost_category_element).addClass('marked');
      } else if(keyval[0] == 'plane_cost_category') {
        plane_cost_category_id = keyval[1];
        if(plane_cost_category_element) {
          $(plane_cost_category_element).removeClass('marked');
        }
        plane_cost_category_element = e.target;
        $(plane_cost_category_element).addClass('marked');
      }
      reload_cost_rules();
    }
  }
}

function update_type(e) {
  var str = e.target.href.split('#').pop();
  if(str) {
    var keyval = str.split('=');
    if(keyval.length == 2) {
      cost_rule_type = keyval[1];
      if(cost_rule_type_element) {
        $(cost_rule_type_element).removeClass('marked');
      }
      cost_rule_type_element = e.target;
      $(cost_rule_type_element).addClass('marked');
      reload_cost_rules();
    }
  }
}

$(function() {
  $('a.update_selection').live('click', update_selection);
  $('a.update_type').live('click', update_type);
});
