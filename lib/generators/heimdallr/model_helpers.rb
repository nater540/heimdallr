module Heimdallr
  module ModelHelpers
    private

    # Indents a content string for the sake of being pretty.
    #
    # @param [String] content The content to indent
    # @return [String]
    def indent_content(content)
      content = content.split("\n").map do |line|
        line.blank? ? line : '  ' + line
      end

      content.join("\n") << "\n"
    end

    # Checks whether or not the database is PostgreSQL.
    #
    # @return [Boolean]
    def postgresql?
      config = ActiveRecord::Base.configurations[Rails.env]
      config && config['adapter'] == 'postgresql'
    end

    # Checks whether or not the model file exists.
    #
    # @return [Boolean]
    def model_exists?
      File.exist?(File.join(destination_root, model_path))
    end

    # Checks whether or not a given migration file exists.
    #
    # @param [String] table_name The migration table name to check for.
    # @return [Boolean]
    def migration_exists?(table_name)
      Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_add_heimdallr_#{table_name}.rb$/).first
    end

    # @return [String]
    def migration_path
      @migration_path ||= File.join('db', 'migrate')
    end

    # @return [String]
    def model_path
      @model_path ||= File.join('app', 'models', "#{file_path}.rb")
    end
  end
end
