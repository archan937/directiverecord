require_relative "test_helper/coverage"

require "minitest/autorun"
require "mocha/setup"

require "bundler"
Bundler.require :default, :development

require "directive_record/gem_ext/active_record/relation/count"
require_relative "application/boot"

def project_file(path)
  File.expand_path "../../#{path}", __FILE__
end

def strip(sql)
  sql.match(/^\n?(\s+)/)
  size = $1.to_s.size
  sql.gsub(/\n\s{#{size}}/, "\n").strip
end
