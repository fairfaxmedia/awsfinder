# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awsfinder/version'

Gem::Specification.new do |spec|
  spec.name          = "awsfinder"
  spec.version       = Awsfinder::VERSION
  spec.authors       = ["John Slee"]
  spec.email         = ["john.slee@fairfaxmedia.com.au"]

  spec.summary       = %q{CLI tool for ad-hoc AWS "find X" tasks.}
  spec.homepage      = "https://github.com/ffxjslee/awsfinder"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "aws-sdk", "~> 2.2"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
