# javascript for the front page
# TODO Rewrite in js

has_focus = true;

update_batch_stats = (page) ->
  setTimeout (->
    # Fetch batch info for given page
    if visible()
      $.getJSON '/batches?page=' + page, (batches) ->
        for batch in batches
          do ->
            states = ['queued', 'running', 'passed', 'failed', 'errored']
            # Loop through each batch
            for state in states
              do ->
                current_value = parseInt($("#batch_" + batch['id'] + "_" + state + "_count").html())
                new_value = batch['jobs_' + state]
                
                # If number of running jobs for given batch & state has changed, update value
                if current_value != new_value
                  $("#batch_" + batch['id'] + "_" + state + "_count").fadeOut 500, () ->
                    $(this).html(new_value)
                    $(this).fadeIn(500)
                    $(this).removeClass('badge-count-' + current_value)
                    $(this).addClass('badge-count-' + new_value)
            batch_state = $("#batch_" + batch['id'] + "_state span").html()
            new_state = batch['state']
            # If the overall state of batch has changed, then update this inline with a lovely little animation
            if batch_state != new_state
              $("#batch_" + batch['id'] + "_state span").fadeOut 500, () ->
                $(this).html(new_state)
                $(this).fadeIn(500)
                $(this).removeClass('result-' + batch_state)
                $(this).addClass('result-' + new_state)

    setTimeout arguments.callee, 15000
    # Repeat the process
  ), 15000

jQuery ->
  $(".switch").bootstrapSwitch();
  $("#search_project_ids").select2({
      placeholder: "Select Projects",
      width: "400px"
    }
  );
  $("#search_project_ids").change (e) ->
    $("#batches_filter").submit()
    return
  $("#search_show_all").on "switchChange.bootstrapSwitch", (event, state) ->
    $("#batches_filter").submit()
    return

  if $('#batch_index').length > 0
    update_batch_stats($('#page').val())


