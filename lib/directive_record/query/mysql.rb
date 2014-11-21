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

      def finalize_options(options)
        regexp = /^\S+/

        options.deep_dup.tap do |options|
          options[:group_by] = %w(NULL) if options[:group_by] == :all

          [:select, :group_by].each do |sym|
            options[sym] = [options[sym]].flatten if options[sym]
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
              select = "#{aggregate_method.to_s.upcase}(IFNULL(#{path}, 0))"
              select_alias = aggregates[path] = quote_alias("#{aggregate_method}:#{path}")
            end
            if scale = scales[path]
              select = "ROUND(#{select}, #{scale})"
              select_alias ||= quote_alias(path)
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
              if options[:select].none?{|x| x.match(/ AS #{path}$/)} && (aggregate_method = (options[:aggregates] || {})[path])
                "#{aggregate_method.to_s.upcase}(IFNULL(#{path}, 0))"
              else
                path
              end
            end

            "#{scale ? "ROUND(#{select}, #{scale})" : select} #{direction.upcase if direction}"
          end

          [:group_by, :having, :order_by].each do |key|
            if sql = options[key]
              options[:aliases].each{|pattern, replacement| sql.gsub! pattern, replacement}
            end
          end if options[:numerize_aliases]

          options.reject!{|k, v| v.blank?}
        end
      end

    end
  end
end
