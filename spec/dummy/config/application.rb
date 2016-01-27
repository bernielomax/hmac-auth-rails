require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "jbuilder"
require "hmac_auth_rails"
require "rspec-rails"
require "factory_girl_rails"
require "devise"



module Dummy
  class Application < Rails::Application
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
    config.active_record.raise_in_transactional_callbacks = true
  end
end

