module DirectiveRecord
  module Query
    class MySQL < SQL

#       def self.to_trend_query(q1, q2, join_column_count, options)
#         i      = join_column_count + 1
#         select = "q1.*, q2.c#{i}, (((q1.c#{i} - q2.c#{i}) / ABS(q2.c#{i})) * 100) AS trend"
#         on     = (1..join_column_count).to_a.collect{|x| "q1.c#{x} = q2.c#{x}"}.join(" AND ")
#         order  = "\nORDER BY #{options[:order]}" if options[:order]
#         limit  = "\nLIMIT #{options[:limit]}" if options[:limit]
#         offset = "\nOFFSET #{options[:offset]}" if options[:offset]
# <<-SQL
# SELECT #{select}
# FROM
# (\n#{q1}\n) q1
# INNER JOIN
# (\n#{q2}\n) q2
# ON #{on}#{order}#{limit}#{offset}
# SQL
#       end

    private

      def quote_alias(sql_alias)
        "`#{sql_alias}`"
      end

      def path_delimiter
        "."
      end

      def select_aggregate_sql(method, path)
        "#{method.to_s.upcase}(IFNULL(#{path}, 0))"
      end

      def select_aggregate_sql_alias(method, path)
        quote_alias "#{method}:#{path}"
      end

      def group_by_all_sql
        "NULL"
      end

      def wrap_up_options!(options)
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
