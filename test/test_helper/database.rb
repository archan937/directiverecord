if Dir.pwd == File.expand_path("../../..", __FILE__)

require "yaml"

config = YAML.load_file(File.expand_path("../../../config/database.yml", __FILE__))["test"]
host, port, user, password, database = config.values_at "host", "port", "username", "password", "database"

`#{
  [
    "mysqldump",
   ("-h #{host}" unless host.to_s.strip.empty?), ("-P #{port}" unless port.to_s.strip.empty?),
    "-u #{user}", ("-p#{password}" unless password.to_s.strip.empty?),
    "--no-create-db --add-drop-table",
    "#{database} > ./db/directive_record.sql"
  ].compact.join(" ")
}`

end
