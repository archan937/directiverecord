ENV["GEM_ENV"] = "test"

require_relative "test_helper/coverage"
require_relative "test_helper/database"

require "minitest/autorun"
require "mocha/setup"

def project_file(path)
  File.expand_path "../../#{path}", __FILE__
end

def strip(sql)
  sql.strip.gsub(/^\s+/m, "")
end

require "bundler"
Bundler.require :default, :development

require_relative "../app/models"
