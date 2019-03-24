module Heimdallr

  # Heimdallr installation generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:install
  # ```
  #
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def self.next_migration_number(path)
      next_migration_number = current_migration_number(path) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    desc 'Installs Heimdallr.'
    def copy_initializer_file
      template 'initializer.rb.erb', 'config/initializers/heimdallr.rb'
    end
  end
end
