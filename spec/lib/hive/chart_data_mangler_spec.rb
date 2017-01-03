require "spec_helper"

describe Hive::ChartDataMangler do

  describe ".pie_result_data" do
    
    it 'creates a value for each state' do
      data = {
        :queued  => 1,
        :running => 2,
        :passed  => 3,
        :failed => 4,
        :errored => 5
      }
      hash = Hive::ChartDataMangler.pie_result_data( data )

      expect(hash).to be_a Hash
      expect(hash[:datasets].first[:data].count).to eq 5
      expect(hash[:labels].first).to eq 'Queued'
    end
    
    it 'copes with sparse data' do
      hash = Hive::ChartDataMangler.pie_result_data( {} )
      expect(hash[:labels].count).to eq 5
      expect(hash[:datasets].first[:data].first).to eq 0
    end
  end
end

