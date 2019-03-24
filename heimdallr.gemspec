$:.push File.expand_path('../lib', __FILE__)

require 'heimdallr/version'

Gem::Specification.new do |spec|
  spec.name        = 'heimdallr'
  spec.version     = Heimdallr::VERSION
  spec.authors     = ['Nate Strandberg']
  spec.email       = %w[nater540@gmail.com]
  spec.homepage    = 'https://github.com/nater540/heimdallr'
  spec.summary     = 'JWT Middleware for Ruby on Rails'
  spec.description = 'JWT Authorization engine'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ['lib']

  spec.cert_chain  = ['certs/heimdallr.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $0 =~ /gem\z/

  spec.add_dependency 'dry-configurable', '~> 0.8.2'
  spec.add_dependency 'jwt', '~> 2.2.0.pre.beta.0'
  spec.add_dependency 'railties', '>= 5.2'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'github-markup'

  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'spring'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'pg', '~> 1.1.4'
  spec.add_development_dependency 'puma', '~> 3.12'
  spec.add_development_dependency 'shoulda-matchers', '~> 4.0.1'
  spec.add_development_dependency 'rake', '>= 12.3'
  spec.add_development_dependency 'rails', '~> 5.2'
  spec.add_development_dependency 'generator_spec', '~> 0.9.3'
  spec.add_development_dependency 'graphql', '>= 1.9.3', '< 2'
  spec.add_development_dependency 'database_cleaner', '~> 1.7.0'
  spec.add_development_dependency 'spring-watcher-listen', '~> 2.0.0'
end
