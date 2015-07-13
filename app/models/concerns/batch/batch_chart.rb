class Batch < ActiveRecord::Base
  module BatchChart
    extend ActiveSupport::Concern

    def chart_data
      data = {
        :queued  => self.total_queued,
        :running => self.total_running,
        :passed  => self.total_passed,
        :failed => self.total_failed,
        :errored => self.total_errored
      }
      Hive::ChartDataMangler.pie_result_data( data )
    end

  end
end
