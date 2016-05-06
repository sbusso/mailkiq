require 'rails_helper'

describe API::V1::SubscribersController, type: :controller do
  context 'when logged in' do
    describe '#create' do
      let(:account) { Fabricate.build :valid_account, id: 10 }
      let(:params) do
        {
          api_key: account.api_key,
          data: {
            type: 'subscribers',
            attributes: {
              name: 'Jonh Doe',
              email: 'jonh@doe.com',
              tags: ['teste']
            }
          }
        }
      end

      before do
        relation = double('relation')

        expect(relation).to receive(:pluck).with(:id).and_return([])
        expect(Tag).to receive(:where)
          .with(name: ['teste'], account_id: account.id)
          .and_return(relation)

        allow(ActiveRecord::Base).to receive(:transaction).and_yield
        expect_sign_in_as account
        expect_any_instance_of(Subscriber).to receive(:valid?).and_return(true)
        expect_any_instance_of(Subscriber).to receive(:save) { |model| model }
        expect_any_instance_of(API::V1::SubscriberResource)
          .to receive(:redefine_model)
      end

      describe 'json response' do
        before do
          set_accept_header!
          post :create, params
        end

        it { is_expected.not_to use_before_action :ensure_correct_media_type! }
        it { is_expected.to use_before_action :authenticate! }
        it { is_expected.to respond_with :created }
        it { expect(response.content_type).to eq JSONAPI::MEDIA_TYPE }
      end

      describe 'redirection' do
        before { post :create, params.merge(redirect_to: 'http://google.com') }

        it { is_expected.not_to use_before_action :ensure_correct_media_type! }
        it { is_expected.to use_before_action :authenticate! }
        it { is_expected.to respond_with :redirect }
        it { is_expected.to redirect_to 'http://google.com' }
      end
    end
  end
end
