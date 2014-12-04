# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vx/lib/shell/version'

Gem::Specification.new do |spec|
  spec.name          = "vx-lib-shell"
  spec.version       = Vx::Lib::Shell::VERSION
  spec.authors       = ["Dmitry Galinsky"]
  spec.email         = ["dima@vexor.io"]
  spec.description   = %q{ Spawn processes in a shell capturing output in realtime. It also allows to set the temeouts. }
  spec.summary       = %q{ This gem helps to spawn processes in a shell capturing output in realtime. It also allows to set the temeouts. }
  spec.homepage      = "https://github.com/vexor/vx-lib-shell"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "net-ssh", "= 2.9.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
