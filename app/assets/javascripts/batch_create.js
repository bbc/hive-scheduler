var batch_create;
batch_create = function () {

    if ($('#new_batch').length) {

        $("#batch_project_id").change(function (e) {
            jQuery.get(Routes.new_batch_path($("#new_batch").serializeHash()), function () {
                queue_remove_item();
                add_array_item();
            });
        });
    }
};

$(document).ready(batch_create);
$(document).on('page:load', batch_create);
