var has_focus, update_batch_stats;

has_focus = true;

update_batch_stats = function(page) {
  return setTimeout((function() {
    if (visible()) {
      $.getJSON('/batches?page=' + page, function(batches) {
        var batch, i, len, results;
        results = [];
        for (i = 0, len = batches.length; i < len; i++) {
          batch = batches[i];
          results.push((function() {
            var batch_state, fn, j, len1, new_state, state, states;
            states = ['queued', 'running', 'passed', 'failed', 'errored'];
            fn = function() {
              var current_value, new_value;
              current_value = parseInt($("#batch_" + batch['id'] + "_" + state + "_count").html());
              new_value = batch['jobs_' + state];
              if (current_value !== new_value) {
                return $("#batch_" + batch['id'] + "_" + state + "_count").fadeOut(500, function() {
                  $(this).html(new_value);
                  $(this).fadeIn(500);
                  $(this).removeClass('badge-count-' + current_value);
                  return $(this).addClass('badge-count-' + new_value);
                });
              }
            };
            for (j = 0, len1 = states.length; j < len1; j++) {
              state = states[j];
              fn();
            }
            batch_state = $("#batch_" + batch['id'] + "_state span").html();
            new_state = batch['state'];
            if (batch_state !== new_state) {
              return $("#batch_" + batch['id'] + "_state span").fadeOut(500, function() {
                $(this).html(new_state);
                $(this).fadeIn(500);
                $(this).removeClass('result-' + batch_state);
                return $(this).addClass('result-' + new_state);
              });
            }
          })());
        }
        return results;
      });
    }
    return setTimeout(arguments.callee, 15000);
  }), 15000);
};

jQuery(function() {
  $(".switch").bootstrapSwitch();
  $("#search_project_ids").select2({
    placeholder: "Select Projects",
    width: "400px"
  });
  $("#search_project_ids").change(function(e) {
    $("#batches_filter").submit();
  });
  $("#search_show_all").on("switchChange.bootstrapSwitch", function(event, state) {
    $("#batches_filter").submit();
  });
  if ($('#batch_index').length > 0) {
    return update_batch_stats($('#page').val());
  }
});