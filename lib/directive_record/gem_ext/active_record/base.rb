module ActiveRecord
  class Base

    def self.to_qry(*args)
      DirectiveRecord::Query.new(self, extract_connection(args)).to_sql(*args)
    end

    def self.qry(*args)
      extract_connection(args).select_rows to_qry(*args)
    end

  private

    def self.extract_connection(args)
      (args[-1][:connection] if args[-1].is_a?(Hash)) || connection
    end

  end
end
