require "directive_record/query/sql"
require "directive_record/query/mysql"

module DirectiveRecord
  module Query

    def self.new(klass)
      class_for(klass.connection.class.name.downcase).new(klass)
    end

  private

    def self.class_for(connection_class)
      if connection_class.include?("mysql")
        MySQL
      else
        raise NotImplementedError, "Connection type not supported"
      end
    end

  end
end
