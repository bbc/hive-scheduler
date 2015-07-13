module Hive
  class ChartDataMangler

    # Given a result count hash, returns the data sets for
    # a pie chart
    def self.pie_result_data( data )
      data.default = 0
      [
        {
          value: data[:queued],
          color:"#3a87ad",
          highlight:"#4a97bd",
          label: "Queued"
        },
        {
          value: data[:running],
          color:"#f89406",
          highlight: "#ffa416",
          label: "Running"
        },
        {
          value: data[:passed],
          color:"#468847",
          highlight: "#569857",
          label: "Passed"
        },
        {
          value: data[:failed],
          color:"#b94a48",
          highlight: "#e94b58",
          label: "Failed"
        },
        {
          value: data[:errored],
          color:"#333333",
          highlight: "#434343",
          label: "Errored"
        }
      ]
    end
  end
end
