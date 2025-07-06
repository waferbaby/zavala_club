require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "active_storage/engine"

Bundler.require(*Rails.groups)

module ZavalaClub
  class Application < Rails::Application
    config.load_defaults 8.0

    config.active_storage.service = :local
    config.assets.paths << Rails.root.join("app/assets/fonts")
    config.autoload_lib(ignore: %w[assets tasks])
    config.generators.system_tests = nil
  end
end
