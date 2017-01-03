module Hive
  class ChartDataMangler

    # Given a result count hash, returns the data sets for
    # a pie chart
    def self.pie_result_data( data )
      data.default = 0
      data = {
        labels: [ "Queued", "Running", "Passed", "Failed", "Errored" ],
        datasets:
        [
          {
              data: [data[:queued], data[:running], data[:passed], data[:failed], data[:errored]],
              backgroundColor: [
                "#3a87ad",
                "#f89406",
                "#569857",
                "#b94a48",
                "#333333",
                ],
              hoverBackgroundColor: [
                "#4a97bd",
                "#ffa416",
                "#569857",
                "#e94b58",
                "#434343"
             ]
         }
        ]
     }
    end

  end
end
