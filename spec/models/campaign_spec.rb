require 'rails_helper'

describe Campaign, type: :model do
  before do
    allow_any_instance_of(DomainValidator).to receive(:validate_each)
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_presence_of :from_name }
  it { is_expected.to validate_presence_of :from_email }
  it { is_expected.to allow_value('jonh@doe.com').for :from_email }
  it { is_expected.not_to allow_value('asdf.com').for :from_email }

  it { is_expected.to belong_to :account }
  it { is_expected.to have_db_index :account_id }
  it { is_expected.to have_db_index([:name, :account_id]).unique }
  it { is_expected.to have_many :messages }

  it { is_expected.not_to have_db_column :messages_count }
  it { is_expected.to have_db_column(:recipients_count).of_type :integer }
  it { is_expected.to have_db_column(:unique_opens_count).of_type :integer }
  it { is_expected.to have_db_column(:unique_clicks_count).of_type :integer }
  it { is_expected.to have_db_column(:rejects_count).of_type :integer }
  it { is_expected.to have_db_column(:bounces_count).of_type :integer }
  it { is_expected.to have_db_column(:complaints_count).of_type :integer }

  it { is_expected.to delegate_method(:credentials).to(:account).with_prefix }
  it { is_expected.to delegate_method(:domain_names).to(:account).with_prefix }

  it { is_expected.to strip_attribute :name }
  it { is_expected.to strip_attribute :subject }
  it { is_expected.to strip_attribute :from_name }
  it { is_expected.to strip_attribute :from_email }

  it { expect(described_class).to respond_to(:sort).with(1).argument }
  it { expect(described_class).to respond_to(:recents) }

  it { is_expected.to have_counter :messages_count }
  it { is_expected.to have_counter :unique_opens_count }
  it { is_expected.to have_counter :unique_clicks_count }
  it { is_expected.to have_counter :rejects_count }
  it { is_expected.to have_counter :bounces_count }
  it { is_expected.to have_counter :complaints_count }

  describe '#queue' do
    it 'memoizes CampaignQueue object' do
      queue = subject.queue
      expect(subject.queue).to eq(queue)
      expect(subject.queue).to be_instance_of CampaignQueue
    end
  end

  describe '#from' do
    it 'concatenates from_name and from_email fields' do
      campaign = Fabricate.build(:campaign)
      from = "#{campaign.from_name} <#{campaign.from_email}>"
      expect(campaign.from).to eq(from)
    end
  end

  describe '#from?' do
    it 'verifies presence of from name and from email columns' do
      campaign = Fabricate.build :campaign

      expect(campaign).to_not be_blank
      expect(campaign).to_not be_blank
      expect(campaign).to be_from

      campaign.from_name = nil
      expect(campaign).not_to be_from
    end
  end

  describe '#duplicate' do
    it 'duplicates current record' do
      campaign = Fabricate.build(:campaign)
      cloned_campaign = campaign.duplicate

      expect(cloned_campaign).not_to be_persisted
      expect(cloned_campaign.name).to end_with(' copy')
      expect(cloned_campaign.sent_at).to be_nil
      expect(cloned_campaign[:recipients_count]).to be_zero
      expect(cloned_campaign[:unique_opens_count]).to be_zero
      expect(cloned_campaign[:unique_clicks_count]).to be_zero
    end
  end

  describe '#validate_from_field' do
    it 'validates format of from virtual attribute' do
      subject.from_name = 'Jonh <x.'
      subject.from_email = 'jonh@doe.com'

      expect(subject).to_not be_valid
      expect(subject.errors).to have_key(:from_name)
      expect(subject.errors.get(:from_name))
        .to include t('activerecord.errors.models.campaign.unstructured_from')
    end
  end
end
