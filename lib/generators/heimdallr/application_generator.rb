require 'rails/generators/active_record'
require_relative 'model_helpers'

module Heimdallr

  # Heimdallr model generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:application APPLICATION_MODEL_NAME
  # ```
  #
  class ApplicationGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates/migrate', __FILE__)

    include Heimdallr::ModelHelpers

    # Checks to see if the application model already exists, if so it will use a change table migration, otherwise it will create a brand new table.
    def copy_migration
      raise StandardError, 'Heimdallr currently only supports PostgreSQL' unless postgresql?

      if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
        migration_template 'existing_application.rb', "db/migrate/add_heimdallr_to_#{table_name}.rb"
      else
        migration_template 'create_applications.rb', "db/migrate/heimdallr_create_#{table_name}.rb"
      end
    end

    # Generates a new model file for the application if necessary.
    def generate_model
      invoke 'active_record:model', [name], migration: false unless model_exists? && behavior == :invoke
    end

    # Adds the application model associations & mixins.
    def inject_model_content
      return unless model_exists?

      class_path = if namespaced?
                     class_name.to_s.split('::')
                   else
                     [class_name]
                   end

      content = <<~RUBY
        include Heimdallr::ApplicationMixin
        has_many :tokens
      RUBY

      inject_into_class(model_path, class_path.last, indent_content(content))
    end

    # Updates the Heimdallr initializer (if it exists) with the application model class name to use.
    def update_initializer
      return unless File.exist?('config/initializers/heimdallr.rb')

      gsub_file 'config/initializers/heimdallr.rb', /#\s*config.application_model = Application/, "config.application_model = #{table_name.classify.safe_constantize}"
    end
  end
end
