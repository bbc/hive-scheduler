//= require html_encoding

var array_field;
array_field = function () {

    if ($('.add_array_element').length) {

        $('.add_array_element').click(function (e) {

                template = $(this).data("template");
                template_parent = $(this).data("template-parent");
                $("#" + template_parent).append(htmlDecode(template)).append("<br/>");

                return false;
            }
        );
    }
};

$(document).ready(array_field);
$(document).on('page:load', array_field);
