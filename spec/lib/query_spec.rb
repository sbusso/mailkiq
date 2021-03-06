require 'spec_helper'
require 'query'

RSpec.describe Query do
  describe '.select_all' do
    it 'returns an array of rows containing the results' do
      expect(described_class).to receive(:prepare).with(:queue_jobs, {})
      expect(ActiveRecord::Base.connection).to receive(:select_all)
        .with(nil, 'Queue jobs')
      described_class.select_all(:queue_jobs)
    end
  end

  describe '.execute' do
    it 'executes the SQL statement' do
      expect(described_class).to receive(:prepare).with(:queue_jobs, {})
      expect(ActiveRecord::Base.connection).to receive(:execute)
        .with(nil, 'Queue jobs')
      described_class.execute(:queue_jobs)
    end
  end

  describe '.prepare' do
    it 'reads query file and normalize string' do
      sql = described_class.prepare(:queue_jobs, with: 'z', campaign_id: 1)

      expect(sql).to_not include "\n"
      expect(sql).to_not include ':with'
      expect(sql).to_not include ':campaign_id'
    end
  end
end
