$LOAD_PATH.unshift File.dirname(__FILE__)

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment', __FILE__)

require 'faker'
require 'rspec/rails'
require 'database_cleaner'
require 'shoulda-matchers'

ActiveRecord::Migration.maintain_test_schema!

ENGINE_RAILS_ROOT = File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.mock_with :rspec

  config.infer_base_class_for_anonymous_controllers = false

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

require 'heimdallr'
