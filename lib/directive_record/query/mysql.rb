module DirectiveRecord
  module Query
    class MySQL < SQL

    private

      def path_delimiter
        "."
      end

      def aggregate_delimiter
        ":"
      end

      def group_by_all_sql
        "NULL"
      end

      def quote_alias(sql_alias)
        "`#{sql_alias}`"
      end

      def finalize_options!(options)
        return unless options[:numerize_aliases]
        [:group_by, :having, :order_by].each do |key|
          if sql = options[key]
            options[:aliases].each do |pattern, replacement|
              sql.gsub! pattern, replacement
            end
          end
        end
      end

    end
  end
end
