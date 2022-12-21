# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elocal_capistrano/version'

Gem::Specification.new do |spec|
  spec.name          = "elocal_capistrano"
  spec.version       = "2.3.8"
  spec.authors       = ["Rob Di Marco"]
  spec.email         = ["rob@elocal.com"]
  spec.summary       = %q{Common eLocal Capistrano tasks}
  spec.description   = %q{Common eLocal Capistrano tasks.  Supports Capistrano 2.0}
  spec.homepage      = "https://github.com/eLocal/elocal_capistrano"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
