# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hangar/version'

Gem::Specification.new do |spec|
  spec.name          = 'hangar'
  spec.version       = Hangar::VERSION
  spec.authors       = ['Chris Brown']
  spec.email         = %w(xoebus@xoeb.us)
  spec.summary       = 'builds .pivotal products'
  spec.description   = 'a cli for building .pivotal products for deployment'
  spec.homepage      = 'https://github.com/concourse/hangar'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'rubyzip', '~> 1.1.6'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
