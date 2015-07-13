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
      array = Hive::ChartDataMangler.pie_result_data( data )
      
      expect(array).to be_a Array
      expect(array.count).to eq 5
      expect(array.first[:value]).to eq 1
      expect(array.first[:label]).to eq 'Queued'
    end
    
    it 'copes with sparse data' do
      array = Hive::ChartDataMangler.pie_result_data( {} )
      expect(array.count).to eq 5
      expect(array.first[:value]).to eq 0
    end
  end
end

