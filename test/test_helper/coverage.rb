if Dir.pwd == File.expand_path("../../..", __FILE__)

require "simplecov"

SimpleCov.coverage_dir "test/coverage"
SimpleCov.start do
  add_group "DirectiveRecord", "lib"
  add_group "App models", "app/models"
  add_group "Test suite", "test"
  add_filter "boot.rb"
end

end
