RSpec.describe Delayed::Job do
  let(:organisation){ workbench.organisation }
  let(:workbench){ create :workbench }

  describe '#locked' do
    let(:job){ Delayed::Job.create handler: "" }
    let(:locked_job){ Delayed::Job.create handler: "", locked_at: Time.now }

    it 'should return locked jobs' do
      expect(Delayed::Job.locked).to match_array [locked_job]
    end
  end

  describe '#max_run_time' do
    let(:job){ create(:gtfs_import, workbench: workbench).import_async }

    it 'should be 10.hours for imports' do
      expect(job.max_run_time).to eq 10.hours
    end
  end

  describe '#for_organisation' do
    let!(:job){ create(:gtfs_import, workbench: workbench); Delayed::Job.last }
    let!(:other_job){ create(:gtfs_import); Delayed::Job.last }

    it 'should return then relevant jobs' do
      expect(job.organisation_id).to eq organisation.id
      expect(job.operation_type).to eq 'import'

      expect(Delayed::Job.for_organisation(organisation)).to match_array [job]
    end
  end

  describe '#reserve' do
    let(:worker){ OpenStruct.new name: 'worker' }

    it 'should not fail' do
      expect{ Delayed::Backend::ActiveRecord::Job.reserve(worker) }.to_not raise_error
    end

    context 'with jobs' do
      let!(:running_job) do
        create(:gtfs_import, workbench: workbench)
        Delayed::Job.first.delete # we delete the Workbench import job
        job = Delayed::Job.last
        job.update locked_at: Time.now, locked_by: 'Foo'
        job
      end
      let!(:job) do
        id = Delayed::Job.last.id
        import = create(:gtfs_import, workbench: workbench)
        Delayed::Job.where('id > ?', id).delete_all
        import.delay(priority: 5).import
      end

      context 'with no other organisation in the queue' do
        it 'should lock the job' do
          Delayed::Backend::ActiveRecord::Job.reserve(worker)
          expect(job.reload.locked_at).to_not be_nil
        end
      end

      context 'with another organisation in the queue' do
        let!(:other_job) do
          id = Delayed::Job.last.id
          import = create(:gtfs_import)
          Delayed::Job.where('id > ?', id).delete_all
          import.delay(priority: 5).import
        end

        it 'should prioritize the other organisation' do
          Delayed::Backend::ActiveRecord::Job.reserve(worker)
          expect(job.reload.locked_at).to be_nil
          expect(other_job.reload.locked_at).to_not be_nil
          Delayed::Backend::ActiveRecord::Job.reserve(worker)
          expect(job.reload.locked_at).to_not be_nil
        end
      end

      context 'with another organisation in the queue but a lower priority' do
        let!(:other_job) do
          id = Delayed::Job.last.id
          import = create(:gtfs_import)
          Delayed::Job.where('id > ?', id).delete_all
          import.delay(priority: 10).import
        end

        it 'should prioritize first job' do
          Delayed::Backend::ActiveRecord::Job.reserve(worker)
          expect(other_job.reload.locked_at).to be_nil
          expect(job.reload.locked_at).to_not be_nil
        end
      end
    end
  end
end
