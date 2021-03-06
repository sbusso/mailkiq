require 'rails_helper'

RSpec.describe DomainIdentity, type: :model do
  let(:domain) { Fabricate.build :domain }

  subject { described_class.new domain }

  let(:ses) { subject.instance_variable_get :@ses }

  before do
    allow(domain).to receive(:save)
    allow(domain).to receive(:destroy)
    allow(domain).to receive(:transaction).and_yield
  end

  describe '#verify!' do
    it 'verifies a new domain identity on SES' do
      expect(ses).to receive(:verify_domain_identity)
        .with(domain: domain.name)
        .and_call_original

      expect(ses).to receive(:verify_domain_dkim)
        .with(domain: domain.name)
        .and_call_original

      subject.verify!

      expect(domain).to be_pending
      expect(domain).to be_dkim_pending
      expect(domain).to be_mail_from_pending
      expect(domain.name).to eq('example.com')
      expect(domain.verification_token.size).to eq(44)
      expect(domain.dkim_tokens.size).to eq(3)
    end

    it 'sets identity notification topics' do
      expect(ses).to receive_set_identity_notification_topic :Bounce
      expect(ses).to receive_set_identity_notification_topic :Complaint
      expect(ses).to receive_set_identity_notification_topic :Delivery

      expect(ses).to receive(:set_identity_feedback_forwarding_enabled)
        .with(identity: domain.name, forwarding_enabled: false)
        .and_call_original

      expect(ses).to receive(:set_identity_mail_from_domain)
        .with(identity: domain.name,
              mail_from_domain: "bounce.#{domain.name}",
              behavior_on_mx_failure: 'UseDefaultValue')
        .and_call_original

      subject.verify!
    end
  end

  describe '#update!' do
    it 'updates domain statuses attributes' do
      expect(ses).to receive(:get_identity_verification_attributes)
        .with(identities: [domain.name])
        .and_call_original

      expect(ses).to receive(:get_identity_dkim_attributes)
        .with(identities: [domain.name])
        .and_call_original

      expect(ses).to receive(:get_identity_mail_from_domain_attributes)
        .with(identities: [domain.name])
        .and_call_original

      expect(ses).to receive(:set_identity_dkim_enabled)
        .with(identity: domain.name, dkim_enabled: true)
        .and_call_original

      subject.update!

      expect(domain).to be_success
      expect(domain).to be_dkim_success
      expect(domain).to be_mail_from_success
    end

    it 'retries DKIM and MAIL FROM identification' do
      expect(domain).to receive(:dkim_success?).and_return(false)
      expect(domain).to receive(:dkim_failed?).and_return(true)
      expect(domain).to receive(:mail_from_failed?).and_return(true)

      expect(subject).to receive(:enable_identity_dkim)
      expect(subject).to receive(:set_identity_mail_from_domain)

      subject.update!
    end
  end

  describe '#delete!' do
    it 'removes domain identity permanently' do
      expect(ses).to receive(:delete_identity)
        .with(identity: domain.name)
        .and_call_original

      subject.delete!
    end
  end

  def receive_set_identity_notification_topic(type)
    receive(:set_identity_notification_topic)
      .with(identity: domain.name,
            sns_topic: domain.account_aws_topic_arn,
            notification_type: type)
      .and_call_original
  end
end
