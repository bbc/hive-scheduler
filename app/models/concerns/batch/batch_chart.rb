class Batch < ActiveRecord::Base
  module BatchChart
    extend ActiveSupport::Concern

    def chart_data
      data = {
        :queued  => self.tests_queued,
        :running => self.tests_running,
        :passed  => self.tests_passed,
        :failed => self.tests_failed,
        :errored => self.tests_errored
      }
      Hive::ChartDataMangler.pie_result_data( data )
    end

  end
end
