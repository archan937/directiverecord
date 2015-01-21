require "directive_record/query/sql"
require "directive_record/query/mysql"
require "directive_record/query/big_query"

module DirectiveRecord
  module Query

    def self.new(klass, connection = nil)
      class_for((connection || klass.connection).class.name.downcase).new(klass)
    end

  private

    def self.class_for(connection_class)
      if connection_class.include?("mysql")
        MySQL
      elsif connection_class.include?("bigquery")
        BigQuery
      else
        raise NotImplementedError, "Connection type not supported"
      end
    end

  end
end
