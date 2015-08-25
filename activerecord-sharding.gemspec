# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/sharding/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-sharding'
  spec.version       = ActiveRecord::Sharding::VERSION
  spec.authors       = ['hirocaster']
  spec.email         = ['hohtsuka@gmail.com']
  spec.summary       = 'Sharding library for ActiveRecord(MySQL)'
  spec.description   = 'Sharding library for ActiveRecord(MySQL)'
  spec.homepage      = 'https://github.com/hirocaster/activerecord-sharding'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency 'activerecord', '>= 4.1.0'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'simplecov'
end
