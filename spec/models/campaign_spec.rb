require 'rails_helper'

describe Campaign, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_presence_of :from_name }
  it { is_expected.to validate_presence_of :from_name }
  it { is_expected.to validate_presence_of :html_text }
  it { is_expected.to allow_value('jonh@doe.com').for :from_email }
  it { is_expected.not_to allow_value('asdf.com').for :from_email }

  it { is_expected.to belong_to :list }
  it { is_expected.to belong_to :account }
  it { is_expected.to have_db_index :account_id }
  it { is_expected.to have_db_index :list_id }
  it { is_expected.to have_db_column(:send_at).of_type :datetime }
end
