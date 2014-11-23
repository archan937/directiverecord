require "yaml"
require "logger"

environment = ENV["GEM_ENV"] || "development"
dbconfig = YAML.load_file(File.expand_path("../../config/database.yml", __FILE__))[environment]
logger = Logger.new(File.expand_path("../../log/#{environment}.log", __FILE__))

ActiveRecord::Base.establish_connection dbconfig
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.logger = logger

Dir[File.expand_path("../models/*.rb", __FILE__)].each{|file| require file}
