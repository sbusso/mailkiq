require 'rails_helper'

RSpec.describe CampaignJob do
  subject { described_class.new args: [1, 1] }

  describe '#run' do
    it 'delivers campaign to the subscriber' do
      expect(ActiveRecord::Base).to receive(:transaction).and_yield
      expect(CampaignMailer).to receive_message_chain :new, :deliver!
      expect(subject).to receive(:destroy).twice
      subject._run
    end

    it 'changes state to unconfirmed when email address is invalid' do
      exception = Aws::SES::Errors::InvalidParameterValue.new nil, nil

      expect(ActiveRecord::Base).to receive(:transaction).and_raise exception
      expect(Appsignal).to receive(:send_exception)
        .with kind_of(exception.class)
      expect(Subscriber).to receive_message_chain(:where, :update_all)
        .with state: Subscriber.states[:invalid_email]
      expect(subject).to receive(:destroy).once
      expect { subject._run }.not_to raise_exception
    end

    it 'requeues job when rate exceeded' do
      exception = Aws::SES::Errors::Throttling.new nil, nil

      expect(ActiveRecord::Base).to receive(:transaction).and_raise exception
      expect(CampaignJob).to receive(:enqueue).with 1, 1
      expect(Appsignal).to receive(:send_exception)
        .with kind_of(exception.class)
      expect(subject).to receive(:destroy).once
      expect { subject._run }.not_to raise_exception
    end
  end
end
