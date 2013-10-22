# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swagger/docs/version'

Gem::Specification.new do |spec|
  spec.name          = "swagger-docs"
  spec.version       = Swagger::Docs::VERSION
  spec.authors       = ["Rich Hollis"]
  spec.email         = ["richhollis@gmail.com"]
  spec.description   = %q{Generates json files for rails apps to use with swagger-ui}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rails"
end
