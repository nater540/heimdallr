module Heimdallr

  # Heimdallr GraphQL types generator.
  #
  # **Usage**
  #
  # ```shell
  # rails g heimdallr:types
  # ```
  #
  class TypesGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates/types', __FILE__)

    desc 'Copies GraphQL types into your application.'
    def copy_types
      FileUtils.mkdir_p 'app/graphql/types'

      copy_file 'algorithm_type_enum.rb', 'app/graphql/types/algorithm_type_enum.rb'
      copy_file 'application_type.rb', 'app/graphql/types/application_type.rb'
      copy_file 'date_time_type.rb', 'app/graphql/types/date_time_type.rb'
      copy_file 'grant_type_enum.rb', 'app/graphql/types/grant_type_enum.rb'
      copy_file 'time_type.rb', 'app/graphql/types/time_type.rb'
      copy_file 'token_type.rb', 'app/graphql/types/token_type.rb'
      copy_file 'uuid_type.rb', 'app/graphql/types/uuid_type.rb'
    end
  end
end
