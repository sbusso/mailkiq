module Helpers
  module API
    def set_content_type_header!
      @request.headers['Content-Type'] = JSONAPI::MEDIA_TYPE
    end

    def expect_sign_in_as(account)
      expect(Account).to receive(:find_by)
        .with(api_key: account.api_key)
        .and_return(account)
    end

    def raw_fixture(path)
      File.read("spec/fixtures/#{path}.json")
    end

    def fixture(path)
      JSON.parse raw_fixture(path)
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::API, type: :controller
end
