require File.expand_path('../boot', __FILE__)

require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module Mailkiq
  class Application < Rails::Application
    config.time_zone = 'Central Time (US & Canada)'
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i(en pt-BR)
    config.filter_parameters += [:password, :api_key]
    config.generators do |g|
      g.helper false
      g.stylesheets false
      g.javascripts false
    end

    config.middleware.delete Rack::Sendfile
    config.middleware.delete Rack::ETag

    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    config.active_record.schema_format = :sql
  end
end
