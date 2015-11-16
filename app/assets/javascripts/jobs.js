var template_preview, update_graph, update_job_stats;

template_preview = function() {
  return $("#project_script_id").change(function() {
    return $.get($(this).attr('data-path') + $(this).val(), function(data) {
      $("#template_preview").html(data);
      return template_preview();
    });
  });
};

update_job_stats = function(batch_id, page) {
  return setTimeout((function() {
    if (visible()) {
      $.getJSON('/batches/' + batch_id + ".json", function(jobs) {
        var fn, i, job, len, update_chart;
        update_chart = false;
        fn = function() {
          var fn1, j, job_state, len1, new_state, state, states;
          states = ['queued', 'running', 'passed', 'failed', 'errored'];
          fn1 = function() {
            var current_value, new_value;
            current_value = parseInt($("#job_" + job['id'] + "_" + state + "_count").html());
            new_value = job[state + '_count'];
            if (isNaN(current_value)) {
              current_value = null;
            }
            if (current_value !== new_value) {
              update_chart = true;
              return $("#job_" + job['id'] + "_" + state + "_count").fadeOut(500, function() {
                $(this).html(new_value != null ? new_value : '?');
                $(this).fadeIn(500);
                $(this).removeClass('badge-count-0');
                $(this).removeClass('badge-count-' + current_value);
                return $(this).addClass('badge-count-' + (new_value != null ? new_value : 0));
              });
            }
          };
          for (j = 0, len1 = states.length; j < len1; j++) {
            state = states[j];
            fn1();
          }
          job_state = $("#job_" + job['id'] + "_state span").html();
          new_state = job['status'];
          if (job_state !== new_state) {
            $("#job_" + job['id'] + "_state span").fadeOut(500, function() {
              $(this).html(new_state);
              $(this).fadeIn(500);
              $(this).removeClass('result-' + job_state);
              return $(this).addClass('result-' + new_state);
            });
            if (new_state === 'running') {
              return $("#job_" + job['id'] + "_device_details").fadeOut(500, function() {
                $(this).html(job['device_details']);
                return $(this).fadeIn(500);
              });
            }
          }
        };
        for (i = 0, len = jobs.length; i < len; i++) {
          job = jobs[i];
          fn();
        }
        if (update_chart) {
          return update_graph(batch_id);
        }
      });
    }
    return setTimeout(arguments.callee, 15000);
  }), 15000);
};

update_graph = function(batch_id) {
  $.get('/batches/' + batch_id + '/chart_data', function(data) {
    var chart = window.Chart['chart_graph']
    for (i = 0; i < data.length; i++) {
      chart.segments[i].value = data[i].value
    }
    chart.update()
  });
};

jQuery(function() {
  if ($('#batch_id').length > 0) {
    return update_job_stats($('#batch_id').val(), $('#page').val());
  }
});