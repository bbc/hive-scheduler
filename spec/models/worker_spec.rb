require 'spec_helper'

describe Worker do

  describe ".identify" do

    let(:reservation_details) { {"hive_id"=>1, "worker_pid"=>8950} }
    let(:queue_names) { ["bash","shell","ruby22"] }

    context "Worker polls for the first time" do

      it 'creates a new worker entry' do
        expect( Worker.identify( reservation_details, queue_names ) ).to be_a Worker
        expect( Worker.where( hive_id: 1, pid: 8950 ).first ).to be_a Worker
      end
      
      it 'creates a unique entry' do
        Worker.identify( reservation_details, queue_names )
        Worker.identify( reservation_details, queue_names )
        expect( Worker.where( hive_id: 1, pid: 8950 ).count ).to eq 1
      end
      
      
      it 'associates the worker with the relevant hive_queues' do
        worker = Worker.identify( reservation_details, queue_names )
        expect( worker.hive_queues.count ).to eq 3
      end
    end
    
    context "Worker has already been identified once" do

      let(:worker) { Worker.identify( reservation_details, queue_names ) }

      it 'retrieves an existing worker' do
        expect(Worker.identify( reservation_details, queue_names )).to eq worker
      end
      
      it 'updates worker queues when the queue names change' do
        worker2 = Worker.identify( reservation_details, [ 'shell' ] )
        expect(worker2).to eq worker
        worker2.hive_queues.collect { |q| q.name }.should == ['shell']
      end
      
    end

  end
 
end
