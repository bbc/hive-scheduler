var execution_type_create;
execution_type_create = function () {

    if ($('.execution_type_form').length) {
        $("#execution_type_target_id").imagepicker( {show_label: true} );
    }
};

$(document).ready(execution_type_create);
$(document).on('page:load', execution_type_create);
