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
  spec.summary       = %q{Generates swagger-ui json files for rails apps with APIs. You add the swagger DSL to your controller classes and then run one rake task to generate the json files.}
  spec.homepage      = "https://github.com/richhollis/swagger-docs"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #spec.cert_chain  = ['certs/gem-public_cert.pem']
  #spec.signing_key = File.expand_path("~/.gemcert/gem-private_key.pem") if $0 =~ /gem\z/

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "appraisal", "~> 1"

  spec.add_runtime_dependency "railties", ">= 3"
  spec.add_runtime_dependency "actionpack", ">= 3"
  spec.add_runtime_dependency "activesupport", ">= 3"
  spec.add_runtime_dependency "rack"
end
