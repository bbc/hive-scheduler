class Job < ActiveRecord::Base
  module JobChart
    extend ActiveSupport::Concern

    def chart_data
      data = {
        :queued  => self.queued_count,
        :running => self.running_count,
        :passed  => self.passed_count,
        :failed => self.failed_count,
        :errored => self.errored_count
      }
      Hive::ChartDataMangler.pie_result_data( data )
    end

  end
end
