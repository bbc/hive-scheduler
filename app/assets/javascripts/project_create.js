var project_create;
project_create = function () {

    if ($('#new_project').length) {

        $("#project_execution_type_id, #project_builder_name").change(function (e) {
            jQuery.get(Routes.new_project_path($("#new_project").serializeHash()), function () {
                queue_remove_item();
                add_array_item();
            });
        });

    }
};

$(document).ready(project_create);
$(document).on('page:load', project_create);
