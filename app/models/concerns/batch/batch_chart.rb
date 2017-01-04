class Batch < ActiveRecord::Base
  module BatchChart
    extend ActiveSupport::Concern

    def chart_data
      data = {
        :queued  => self.jobs_queued,
        :running => self.jobs_running,
        :passed  => self.jobs_passed,
        :failed => self.jobs_failed,
        :errored => self.jobs_errored
      }
      Hive::ChartDataMangler.pie_result_data( data )
    end

  end
end
