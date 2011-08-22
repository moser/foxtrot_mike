$(function() {
  $('.linked').bind('change', function(e) {
    $('.linked[data-link-group='+ $(this).attr('data-link-group') +']').val($(this).val());
  });
});
