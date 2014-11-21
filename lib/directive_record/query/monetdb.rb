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

      def finalize_options(options)
        regexp = /^\S+/

        options.deep_dup.tap do |options|
          options[:group_by] = %w(all_rows) if options[:group_by] == :all

          [:select, :group_by].each do |sym|
            options[sym] = [options[sym]].flatten if options[sym]
          end

          [:select, :where, :having, :group_by, :order_by].each do |sym|
            if options[sym]
              base.reflections.keys.each do |association|
                options[sym] = [options[sym]].flatten.collect{|x| x.gsub(/^#{association}\.([a-z_\.]+)/) { "#{association}_#{$1.gsub(".", "_")}" }}
              end
            end
          end

          scales = options[:select].uniq.inject({}) do |hash, x|
            hash[x] = column_for(x).try :scale
            hash
          end

          aggregates = {}
          options[:aliases] = {}

          options[:select] = options[:select].inject([]) do |array, path|
            select = path
            select_alias = nil

            if aggregate_method = (options[:aggregates] || {})[path]
              select = "#{aggregate_method.to_s.upcase}(#{path})"
              select_alias = aggregates[path] = "#{aggregate_method}__#{path}"
            end
            if scale = scales[path]
              select = "ROUND(#{select}, #{scale})"
              select_alias ||= "#{path}"
            end
            if options[:numerize_aliases]
              select = select.gsub(/ AS .*$/, "")
              select_alias = options[:aliases][prepend_base_alias(base, base_alias, select_alias || select)] = "c#{array.size + 1}"
            end

            array << [select, select_alias].compact.join(" AS ")
            array
          end

          where, having = (options[:where] || []).partition{|statement| !aggregates.keys.include?(statement.strip.match(regexp).to_s)}

          options[:where] = where
          unless (attrs = base.scope_attributes).blank?
            sql = base.send(:sanitize_sql_for_conditions, attrs, "").gsub(/``.`(\w+)`/) { $1 }
            options[:where] << sql
          end

          options[:having] = having.collect{|statement| statement.strip.gsub(regexp){|path| aggregates[path]}}
          [:where, :having].each do |key|
            options[key] = options[key].collect{|x| "(#{x})"}.join(" AND ")
          end

          options[:order_by] ||= begin
            (options[:group_by] || []).collect do |path|
              direction = (path.to_s == "date") ? "DESC" : "ASC"
              "#{path} #{direction}"
            end
          end

          options[:order_by] = [options[:order_by]].flatten.collect do |x|
            path, direction = x.split " "

            scale = scales[path]
            select = begin
              if aggregate_method = (options[:aggregates] || {})[path]
                "#{aggregate_method.to_s.upcase}(#{path})"
              else
                path
              end
            end

            "#{scale ? "ROUND(#{select}, #{scale})" : select} #{direction.upcase if direction}"
          end

          if options[:having]
            if options[:numerize_aliases]
              map = Hash[select.scan(/,?\s?(.*?) AS ([^,]+)/).collect(&:reverse)]
              options[:aliases].each{|pattern, replacement| options[:having].gsub! pattern, map[replacement]}
            else
              (options[:aggregates] || {}).each do |path, aggregate|
                options[:having].gsub! /\b#{aggregate}__#{path}\b/, "#{aggregate.to_s.upcase}(#{path})"
              end
            end
          end

          options[:select] = options[:select].split(", ").collect do |string|
            expression, query_alias = string.match(/^(.*) AS (.*)$/).try(:captures)
            if query_alias
              options[:group_by].to_s.include?(expression) || !expression.match(/^\w+(\.\w+)*$/) ? string : "MAX(#{expression}) AS #{query_alias}"
            else
              string.match(/^\w+(\.\w+)*$/) ? "MAX(#{string})" : string
            end
          end.join(", ") if options[:group_by]

          options.reject!{|k, v| v.blank?}
        end
      end

    end
  end
end
