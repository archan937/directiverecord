require_relative "test_helper/coverage"

require "minitest/autorun"
require "mocha/setup"

require "bundler"
Bundler.require :default, :development

require_relative "test_helper/nulldb"
require_relative "application/boot"

def project_file(path)
  File.expand_path "../../#{path}", __FILE__
end

def strip(sql)
  sql.strip.gsub(/^\s+/m, "")
end
