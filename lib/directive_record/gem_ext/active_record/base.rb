module ActiveRecord
  class Base

    def self.to_qry(*args)
      DirectiveRecord::Query.new(self, extract_connection(args)).to_sql(*args)
    end

    def self.qry(*args)
      extract_connection(args).select_rows to_qry(*args)
    end

    def self.to_trend_qry(q1, q2, join_column_count, options)
      DirectiveRecord::Query.new(self).to_trend_sql(q1, q2, join_column_count, options)
    end

  private

    def self.extract_connection(args)
      (args[-1][:connection] if args[-1].is_a?(Hash)) || connection
    end

  end
end
