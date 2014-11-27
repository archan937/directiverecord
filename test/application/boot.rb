
config = YAML.load_file(File.expand_path("../config/database.yml", __FILE__))
host, port, username, password, database = config.values_at *%w(host port username password database)
db = File.expand_path("../db", __FILE__)

begin
  ActiveRecord::Base.establish_connection config.merge("database" => nil)
  ActiveRecord::Base.connection.create_database database, {:charset => "utf8", :collation => "utf8_unicode_ci"}

  puts "Installing #{database} ..."

  `#{
    [
      "mysql",
     ("-h #{host}" unless host.blank?), ("-P #{port}" unless port.blank?),
      "-u #{username || "root"}", ("-p#{password}" unless password.blank?),
      "#{database} < #{db}/database.sql"
    ].compact.join(" ")
  }`

rescue Exception => e
  raise e unless e.message.include?("database exists")
end

ActiveRecord::Base.establish_connection config

Dir[File.expand_path("../app/**/*.rb", __FILE__)].each{|file| require file}
