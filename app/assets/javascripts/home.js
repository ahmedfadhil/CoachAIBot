// Semicolon (;) to ensure closing of earlier scripting
// Encapsulation
// $ is assigned to jQuery
;(function($) {

    // DOM Ready
    $(function() {

        // Binding a click event
        // From jQuery v.1.7.0 use .on() instead of .bind()
        $('#btn_login_1').bind('click', function(e) {

            // Prevents the default action to be triggered.
            e.preventDefault();

            // Triggering bPopup when click event is fired
            $('#login_pop_up').bPopup();

        });

    });

    // DOM Ready
    $(function() {

        // Binding a click event
        // From jQuery v.1.7.0 use .on() instead of .bind()
        $('#btn_login_2').bind('click', function(e) {

            // Prevents the default action to be triggered.
            e.preventDefault();

            // Triggering bPopup when click event is fired
            $('#login_pop_up').bPopup();

        });

    });


})(jQuery);

var $sheet = $('.mdl-sheet');

if ($sheet.length > 0) {
    $('html').on('click', function () {
        $sheet.removeClass('mdl-sheet--opened')
    });

    $sheet.on('click', function (event) {
        event.stopPropagation();

        $sheet.addClass('mdl-sheet--opened');
    });
}