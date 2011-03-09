$(function() {
  $("table.filtered").each(function(i, e) {
    e = $(e);
    filter_by = e.attr("data-filter-by").split(",");
    var elems = {};
    var handler = function() {
      filter = "tr";
      n = 0;
      for (k in elems) {
        if(elems[k] && elems[k].val() && elems[k].val() != "") {
          filter += "[data-"+ k + (k == "filter_string" ? "*=" : "=") + "\"" + elems[k].val().toLowerCase() + "\"]"
          n++;
        }
      }
      e.find("tr:not(.no_filter)").hide();
      //console.log(filter);
      e.find(filter).show();
    }
    for (k in filter_by) {
      var f = e.find("#" + filter_by[k]);
      if(f) {
        elems[filter_by[k]] = $(f);
        f.change(handler);
        f.keyup(handler);
      }
    }
  });
});
