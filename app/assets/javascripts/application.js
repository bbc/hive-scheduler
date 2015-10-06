// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require Chart
//= require cocoon
//= require js-routes
//= require jquery.serialize-hash
//= require select2
//= require bootstrap-switch
//= require image-picker
//= require handlebars-v2.0.0
//= require_tree .

var queue_remove_item;
queue_remove_item = function () {
    if ($('.remove_array_element').length) {
        $(".remove_array_element").click(function (e) {

            elementId = $(this).data("element-id");
            $("#" + elementId).remove();

            return false;
        });
    }
};

$(document).ready(queue_remove_item);
$(document).on('page:load', queue_remove_item);

var add_array_item;
add_array_item = function (evt) {

    if ($('.add_array_item').length) {
        $(".add_array_item").click(function (e) {

            fieldName = $(this).data("field-name");

            index = $("." + fieldName + "_item").size()+1;

            templateId = $(this).data("template-id");
            templateParent = $(this).data("template-parent");

            var source = $("#" + templateId).html();
            var template = Handlebars.compile(source);

            var html    = template({index: index});

            $("#" + templateParent).append(html);

            queue_remove_item();
            evt.stopPropagation();
            return false;

        });
    }
};

$(document).ready(add_array_item);
$(document).on('page:load', add_array_item);
