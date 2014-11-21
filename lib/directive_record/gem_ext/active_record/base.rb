module ActiveRecord
  class Base

    def self.to_qry(options)
      DirectiveRecord::Query.new(self).to_sql(options)
    end

    def self.qry(options = {})
      connection.select_rows to_qry(options)
    end

  end
end
