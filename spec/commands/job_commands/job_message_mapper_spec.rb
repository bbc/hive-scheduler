require "spec_helper"

describe JobCommands::JobMessageMapper do
  include Rails.application.routes.url_helpers

  describe "validations" do
    it { should validate_presence_of(:job) }
  end

  describe "#perform" do

    before(:each) do
      Job.stub(publish_to_queue: nil)
    end
    let(:job) { Fabricate(:job, job_attributes) }

    let(:job_attributes) do
      {
          job_group:           job_group,
          execution_variables: job_execution_variables
      }
    end


    let(:execution_type) { Fabricate(:execution_type, template: File.read("spec/fixtures/files/erb_template.erb")) }
    let(:project) { Fabricate(:project, execution_type: execution_type) }

    let(:batch) { Fabricate(:batch, project: project, target_information: {location_url: "http://www.bbc.co.uk"}, execution_variables: batch_execution_variables) }


    let(:job_group) { Fabricate(:job_group, batch: batch, execution_variables: job_group_execution_variables) }

    let(:all_execution_variables) do
      all_execution_variables = base_execution_variables.
          merge!(batch_execution_variables).
          merge!(job_group_execution_variables).
          merge!(job_execution_variables)



      project.builder.execution_variables_required.each do |field|
        all_execution_variables[field.name.to_sym]=field.default_value
      end

      project.execution_type.execution_variables.each do |field|
        all_execution_variables[field.name.to_sym]=field.default_value
      end

      all_execution_variables

    end
    let(:base_execution_variables) { { version: batch.version.to_s, job_id: job.id, queue_name: job_group.queue_name } }

    let(:batch_execution_variables) { { tests: %w(test1 test2) } }
    let(:job_group_execution_variables) { { job_group_variable_one: "job_group_variable_one_value" } }
    let(:job_execution_variables) { { job_variable_one: "job_variable_one_value" } }


    let(:job_message_mapper) { JobCommands::JobMessageMapper.new(job: job) }
    let(:job_message) { job_message_mapper.perform }

    subject { job_message }

    it { should be_instance_of(Hive::Messages::Job) }

    describe "job message attributes" do

      it "does not parse erb in the execution script" do
        expect(job_message.command).to eq '<%= marshal_dump.to_json %>'
      end

      it "provides all the required execution_variables" do
        expect(job_message.execution_variables.to_hash).to eq all_execution_variables
      end

      its(:job_id)              { should eq job.id }
      its(:repository)          { should eq project.repository }
      its(:execution_directory) { should eq project.execution_directory }
      its(:target)              { should eq batch.target_information.stringify_keys.merge(build: batch_download_build_path(batch.id)) }

      it "sets the job_id" do
        expect(job_message.job_id).to eq job.id
      end
    end
  end
end

