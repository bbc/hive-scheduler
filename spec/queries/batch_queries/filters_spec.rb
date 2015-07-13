require "spec_helper"

describe BatchQueries::Filters do

  let(:batch_query) { BatchQueries::Filters.new(params) }

  describe "instance methods" do

    describe "#scope" do

      let(:resulting_batches) { batch_query.scope }

      context "no query parameters provided" do

        let!(:batches) { 10.times.collect { |i| Fabricate(:batch, created_at: i.days.ago) } }

        let(:params) { {} }
        subject { resulting_batches }

        its(:size) { should == 10 }
        it "fetches all batches ordered by the most recent first" do
          expect(resulting_batches).to eq Batch.order(created_at: :desc)
        end
      end

      context "with query parameters" do

        context "status filter" do

          let!(:queued_batches) { Fabricate.times(3, :queued_batch) }
          let!(:running_batches) { Fabricate.times(4, :running_batch) }
          let!(:passed_batches) { Fabricate.times(6, :passed_batch) }

          let!(:failed_batches) { Fabricate.times(7, :failed_batch) }
          let!(:errored_batches) { Fabricate.times(8, :errored_batch) }

          let(:all_batches) do
            queued_batches | running_batches | passed_batches | failed_batches | errored_batches
          end

          let(:failed_and_errored_batches) { failed_batches | errored_batches }

          let(:params) { { show_all: show_all } }

          context "show_all is true" do

            let(:show_all) { true }

            it "returns all batches no matter what state they are in" do
              expect(resulting_batches).to match_array(all_batches)
            end
          end

          context "show_all is false" do

            let(:show_all) { false }

            xit "returns only failed and errored batches" do
              expect(resulting_batches).to match_array(failed_and_errored_batches)
            end
          end
        end

        context "search by project" do

          let(:project_one) { Fabricate(:project) }
          let(:project_two) { Fabricate(:project) }

          let!(:project_one_batches) { Fabricate.times(4, :batch, project: project_one, name: "Project One Batch") }
          let!(:project_two_batches) { Fabricate.times(6, :batch, project: project_one, name: "Project Two Batch") }
          let!(:other_batches) { Fabricate.times(10, :batch) }

          context "project_ids are provided correctly" do




            let(:params) { { project_ids: [project_one.id, project_two.id] } }

            it "only fetches the batches for the required projects" do
              expect(resulting_batches).to match_array(project_one_batches | project_two_batches)
            end
          end

          context "project_ids are passed as an array of a single empty string" do

            let(:params) { { project_ids: [""] } }

            it "fetches all batches" do
              expect(resulting_batches).to match_array(project_one_batches | project_two_batches | other_batches)
            end
          end
        end
      end
    end
  end
end
