require_relative "test_helper/coverage"

require "minitest/autorun"
require "mocha/setup"

def project_file(path)
  File.expand_path "../../#{path}", __FILE__
end

require "bundler"
Bundler.require :default, :development
