(function() {
  $(function() {
    return $(".close").click(function(e) {
      e.preventDefault();
      return $(this).parent().parent().remove();
    });
  });

}).call(this);
