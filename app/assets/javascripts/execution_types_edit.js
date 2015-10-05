var script_create;
script_create = function () {

    if ($('.script_form').length) {
        $("#script_target_id").imagepicker( {show_label: true} );
    }
};

$(document).ready(script_create);
$(document).on('page:load', script_create);
