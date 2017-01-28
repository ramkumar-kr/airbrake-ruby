require 'spec_helper'

RSpec.describe Airbrake::ActivejobSender do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end
  subject(:job) { Airbrake::ActivejobSender.perform_later(YAML.dump(error)) }
  # subject(:job) { Airbrake.notify_job(error) }
  let(:error) { RuntimeError.new('test') }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(described_class.queue_name).to eq('default')
  end

  it 'executes notify_sync with the error' do
    expect(Airbrake).to receive(:notify_sync).with(error, {})
    perform_enqueued_jobs { job }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
