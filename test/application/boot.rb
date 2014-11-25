ActiveRecord::Base.establish_connection :adapter => :nulldb, :schema => File.expand_path("../db/schema.rb", __FILE__)

klass = ActiveRecord::Base.connection.class

def klass.name
  "activerecord::connectionadapters::mysql2adapter"
end

Dir[File.expand_path("../app/**/*.rb", __FILE__)].each{|file| require file}
