module Helpers
  def set_accept_header!
    @request.headers['Accept'] = JSONAPI::MEDIA_TYPE
  end

  def expect_sign_in_as(account)
    expect(Account).to receive(:find_by)
      .with(api_key: account.api_key)
      .and_return(account)
  end

  def fixture(path, json: false)
    source = File.read("spec/fixtures/#{path}.json")
    json ? JSON.parse(source, symbolize_names: true) : source
  end
end

RSpec.configure do |config|
  config.include Helpers
end
