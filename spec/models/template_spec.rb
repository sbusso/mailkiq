require 'rails_helper'

describe Template, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :html_text }

  it { is_expected.to belong_to :account }
  it { is_expected.to have_db_index :account_id }
end
