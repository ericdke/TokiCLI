# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'TokiCLI/version'

Gem::Specification.new do |spec|
  spec.name          = "TokiCLI"
  spec.version       = TokiCLI::VERSION
  spec.authors       = ["Eric Dejonckheere"]
  spec.email         = ["eric@aya.io"]
  spec.summary       = %q{Toki.app command-line client and API server}
  spec.description   = %q{Toki.app command-line client: read your Toki data from the local database or from the App.net backup channel. Show the log for an app, the top apps, the grand total, usage by day or range of days, etc. Use the API in another app, or launch the local server.}
  spec.homepage      = "https://github.com/ericdke/TokiCLI"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '< 2.2.0'

  spec.add_dependency "thor", "~> 0.18"
  spec.add_dependency "rest-client", "~> 1.6"
  spec.add_dependency "amalgalite", "~> 1.3"
  spec.add_dependency "terminal-table", "~> 1.4"
  spec.add_dependency "CFPropertyList", "~> 2.2"
  spec.add_dependency 'sinatra', '~> 1.4', '>= 1.4.5'
  spec.add_dependency "thin", "~> 1.6"
  spec.add_dependency 'sinatra-assetpack', "~> 0.3", '>= 0.3.2'
  spec.add_dependency "sinatra-contrib", '~> 1.4', '>= 1.4.2'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coveralls"
end
