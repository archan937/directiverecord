module ActiveRecord
  class Base

    def self.to_qry(*args)
      DirectiveRecord::Query.new(self).to_sql(*args)
    end

    def self.qry(*args)
      connection.select_rows to_qry(*args)
    end

  end
end
