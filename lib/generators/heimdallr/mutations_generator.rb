module Heimdallr

  # Heimdallr GraphQL mutations generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:mutations
  # ```
  #
  class MutationsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates/mutations', __FILE__)

    desc 'Copies GraphQL mutations into your application.'
    def copy_types
      FileUtils.mkdir_p 'app/graphql/mutations/applications'
      FileUtils.mkdir_p 'app/graphql/mutations/tokens'

      copy_file 'applications/create.rb', 'app/graphql/mutations/applications/create.rb'
      copy_file 'tokens/create.rb', 'app/graphql/mutations/tokens/create.rb'
    end
  end
end
