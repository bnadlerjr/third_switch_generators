# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "third_switch_generators/version"

Gem::Specification.new do |s|
  s.name        = "third_switch_generators"
  s.version     = ThirdSwitchGenerators::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bob Nadler, Jr."]
  s.email       = ["bnadlerjr@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Various Rails 3 Generators}
  s.description = %q{}

  s.rubyforge_project = "third_switch_generators"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
