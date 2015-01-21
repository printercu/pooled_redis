lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pooled_redis/version'

Gem::Specification.new do |spec|
  spec.name          = 'pooled_redis'
  spec.version       = PooledRedis::VERSION
  spec.authors       = ['Max Melentiev']
  spec.email         = ['melentievm@gmail.com']
  spec.summary       = %q{Simple way to access redis connections without global variables.}
  spec.description   = %q{Provides `Rails.redis_pool` & `Rails.redis` methods and configuration via `database.yml`.}
  spec.homepage      = 'https://github.com/printercu/pooled_redis'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'redis', '~> 3.0'
  spec.add_dependency 'connection_pool', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
