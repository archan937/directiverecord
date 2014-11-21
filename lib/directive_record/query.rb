require "directive_record/query/sql"
require "directive_record/query/mysql"
require "directive_record/query/monetdb"

module DirectiveRecord
  module Query

    def self.new(klass)
      class_for(klass.connection.class.name.downcase).new(klass)
    end

  private

    def self.class_for(connection_class)
      if connection_class.include?("mysql")
        MySQL
      elsif connection_class.include?("monetdb")
        MonetDB
      else
        raise NotImplmentedError
      end
    end

  end
end
