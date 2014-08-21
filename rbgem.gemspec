# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gem-template/version"

Gem::Specification.new do |s|
  s.name              = "gtl"
  s.version           = GemTemplate::VERSION
  s.authors           = ["nirnanaaa"]
  s.email             = ["mosny@zyg.li"]
  s.homepage          = "https://github.com/nirnanaaa/gem-template"
  s.summary           = %q{Gem Template for Ruby}
  s.description       = %q{Template for a rubygem}

  s.rubyforge_project = s.name
  s.license           = "GPLv3"

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths     = ["lib"]


  s.add_development_dependency "rake", "~> 10.1"
  s.add_dependency "thor"
end
