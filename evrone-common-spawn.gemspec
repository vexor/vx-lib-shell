# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'evrone/common/spawn/version'

Gem::Specification.new do |spec|
  spec.name          = "evrone-common-spawn"
  spec.version       = Evrone::Common::Spawn::VERSION
  spec.authors       = ["Dmitry Galinsky"]
  spec.email         = ["dima.exe@gmail.com"]
  spec.description   = %q{ Spawn system, ssh processes, capturing output in realtime,
allow to set temeouts and read timeouts }
  spec.summary       = %q{ This gem helps to spawn system, ssh processes, capturing output in realtime,
allow to set temeouts and read timeouts }
  spec.homepage      = "https://github.com/evrone/evrone-common-spawn"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "net-ssh", "~> 2.6"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
