require 'rails/generators/active_record'
require_relative 'model_helpers'

module Heimdallr

  # Heimdallr model generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:token
  # ```
  #
  class TokenGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates/migrate', __FILE__)

    include Heimdallr::ModelHelpers

    # Copies the token migration file.
    def copy_migration
      raise StandardError, 'Heimdallr currently only supports PostgreSQL' unless postgresql?

      if (behavior == :invoke && model_exists?) || (behavior == :revoke && migration_exists?(table_name))
        migration_template 'existing_token.rb', "db/migrate/add_heimdallr_to_#{table_name}.rb"
      else
        migration_template 'create_tokens.rb', "db/migrate/heimdallr_create_#{table_name}.rb"
      end
    end

    # Generates a new model file for the token if necessary.
    def generate_model
      invoke 'active_record:model', [name], migration: false unless model_exists? && behavior == :invoke
    end

    # Adds the token model associations & mixins.
    def inject_model_content
      return unless model_exists?

      class_path = if namespaced?
                     class_name.to_s.split('::')
                   else
                     [class_name]
                   end

      content = <<~RUBY
        include Heimdallr::TokenMixin

        # Support token refreshing
        include Heimdallr::Models::Refreshable

        # Support token revoking
        include Heimdallr::Models::Revocable

        belongs_to :#{application_table_name}
        alias_attribute :application, :#{application_table_name}
      RUBY

      inject_into_class(model_path, class_path.last, indent_content(content))
    end

    # Updates the Heimdallr initializer (if it exists) with the application model class name to use.
    def update_initializer
      return unless File.exist?('config/initializers/heimdallr.rb')

      gsub_file 'config/initializers/heimdallr.rb', /#\s*config.token_model = Token/, "config.token_model = #{table_name.classify.safe_constantize}"
    end

    private

    # Returns the singular application table name (used for associations)
    #
    # @return [String]
    def application_table_name
      Heimdallr.config&.application_model&.name&.underscore&.singularize&.split('::')&.last || 'jwt_application'
    end
  end
end
