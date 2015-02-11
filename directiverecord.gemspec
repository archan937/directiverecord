# -*- encoding: utf-8 -*-
require File.expand_path("../lib/directive_record/version", __FILE__)

Gem::Specification.new do |gem|
  gem.author        = "Paul Engel"
  gem.email         = "pm_engel@icloud.com"
  gem.summary       = %q{A layer on top of ActiveRecord for using paths within queries without thinking about association joins}
  gem.description   = %q{A layer on top of ActiveRecord for using paths within queries without thinking about association joins}
  gem.homepage      = "https://github.com/archan937/directiverecord"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "directiverecord"
  gem.require_paths = ["lib"]
  gem.version       = DirectiveRecord::VERSION
  gem.licenses      = ["MIT"]

  gem.add_dependency "activerecord", ">= 3.2.13"
  gem.add_dependency "arel", "< 6.0.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "mysql2"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "mocha"
end
