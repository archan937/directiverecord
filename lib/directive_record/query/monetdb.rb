module DirectiveRecord
  module Query
    class MonetDB < SQL

#       def self.to_trend_query(q1, q2, join_column_count, options)
#         i      = join_column_count + 1
#         select = "q1.*, q2.c#{i}, CASE WHEN q2.c#{i} = 0 THEN NULL ELSE (((q1.c#{i} - q2.c#{i}) / ABS(q2.c#{i})) * 100) END AS trend"
#         on     = (1..join_column_count).to_a.collect{|x| "q1.c#{x} = q2.c#{x}"}.join(" AND ")
#         order  = "\nORDER BY #{options[:order]}" if options[:order]
#         limit  = "\nLIMIT #{options[:limit]}" if options[:limit]
#         offset = "\nOFFSET #{options[:offset]}" if options[:offset]
# <<-SQL
# WITH
# q1 AS (\n#{q1}\n),
# q2 AS (\n#{q2}\n)
# SELECT #{select}
# FROM q1
# INNER JOIN q2 ON #{on}#{order}#{limit}#{offset}
# SQL
#       end

    private

      def path_delimiter
        "__"
      end

      def select_aggregate_sql(method, path)
        "#{method.to_s.upcase}(#{path})"
      end

      def select_aggregate_sql_alias(method, path)
        "#{method}#{path_delimiter}#{path}"
      end

      def group_by_all_sql
        "all_rows"
      end

      def prepare_options!(options)
        [:select, :where, :having, :group_by, :order_by].each do |key|
          if value = options[key]
            base.reflections.keys.each do |association|
              options[key] = [value].flatten.collect{|x| x.gsub(/^#{association}\.([a-z_\.]+)/) { "#{association}_#{$1.gsub(".", "_")}" }}
            end
          end
        end
      end

      def wrap_up_options!(options)
        if options[:having]
          if options[:numerize_aliases]
            map = Hash[options[:select].scan(/,?\s?(.*?) AS ([^,]+)/).collect(&:reverse)]
            options[:aliases].each{|pattern, replacement| options[:having].gsub! pattern, map[replacement]}
          else
            (options[:aggregates] || {}).each do |path, aggregate|
              options[:having].gsub! /\b#{aggregate}__#{path}\b/, "#{aggregate.to_s.upcase}(#{path})"
            end
          end
        end

        options[:select] = options[:select].collect do |string|
          expression, query_alias = string.match(/^(.*) AS (.*)$/).try(:captures)
          if query_alias
            options[:group_by].to_s.include?(expression) || !expression.match(/^\w+(\.\w+)*$/) ? string : "MAX(#{expression}) AS #{query_alias}"
          else
            string.match(/^\w+(\.\w+)*$/) ? "MAX(#{string})" : string
          end
        end.join(", ") if options[:group_by]
      end

    end
  end
end
