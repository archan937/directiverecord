module DirectiveRecord
  module Query
    class SQL

      def initialize(base)
        @base = base
      end

      def to_sql(*args)
        options = to_options(args)
        validate_options! options

        original_options = options.deep_dup
        original_options.reject!{|k, v| v.nil?}

        check_path_delimiter! options
        optimize_query! options

        prepare_options! options
        normalize_options! options, original_options

        parse_joins! options

        prepend_base_alias! options
        finalize_options! options

        flatten_options! options
        compose_sql options
      end

      def to_trend_sql(q1, q2, join_column_count, options)
        i      = join_column_count + 1
        select = "q1.*, q2.c#{i}, (((q1.c#{i} - q2.c#{i}) / ABS(q2.c#{i})) * 100) AS trend"
        on     = (1..join_column_count).to_a.collect{|x| "q1.c#{x} = q2.c#{x}"}.join(" AND ")
        order  = "\nORDER BY #{options[:order]}" if options[:order]
        limit  = "\nLIMIT #{options[:limit]}" if options[:limit]
        offset = "\nOFFSET #{options[:offset]}" if options[:offset]
<<-SQL
SELECT #{select}
FROM
(\n#{q1}\n) q1
INNER JOIN
(\n#{q2}\n) q2
ON #{on}#{order}#{limit}#{offset}
SQL
      end

    private

      def path_delimiter; end

      def aggregate_delimiter
        raise NotImplementedError
      end

      def select_aggregate_sql(method, path)
        "#{method.to_s.upcase}(#{path})"
      end

      def select_aggregate_sql_alias(method, path)
        quote_alias("#{method}#{aggregate_delimiter}#{path}")
      end

      def base
        @base
      end

      def base_alias
        @base_alias ||= quote_alias(base.table_name.split("_").collect{|x| x[0]}.join(""))
      end

      def quote_alias(sql_alias)
        sql_alias
      end

      def to_options(args)
        options = args.extract_options!.deep_dup
        options.reverse_merge! :select => (args.empty? ? "*" : args)

        [:select, :where, :group_by, :order_by].each do |key|
          if value = options[key]
            options[key] = [value].flatten
          end
        end

        options
      end

      def validate_options!(options)
        options.assert_valid_keys :connection, :select, :subselect, :where, :ignore_where, :group_by, :order_by, :limit, :offset, :aggregates, :numerize_aliases, :period, :optimize
      end

      def optimize_query!(options)
        select = options[:select]
        if options[:optimize] && (select != %w(id)) && select.any?{|x| x.match(/^\w+(\.\w+)+$/)}
          ids = base.connection.select_values(to_sql(options.merge(:select => "id"))).uniq + [0]
          options[:where] = ["id IN (#{ids.join(", ")})"]
          options.delete :limit
          options.delete :offset
        end
      end

      def check_path_delimiter!(options)
        unless path_delimiter
          [:select, :where, :having, :group_by, :order_by].each do |key|
            if value = options[key]
              value.collect! do |val|
                base.reflections.keys.inject(val) do |v, association|
                  v.gsub(/\b#{association}\.([a-z_\.]+)/) { "#{association}_#{$1.gsub(".", "_")}" }
                end
              end
            end
          end
        end
      end

      def prepare_options!(options); end

      def normalize_options!(options, original_options)
        normalize_select!(options)
        normalize_subselect!(options, original_options)
        normalize_from!(options)
        normalize_where!(options)
        normalize_group_by!(options)
        normalize_order_by!(options)
        options.reject!{|k, v| v.blank?}
      end

      def normalize_select!(options)
        options[:select].uniq!

        options[:scales] = options[:select].inject({}) do |hash, sql|
          if scale = column_for(sql).try(:scale)
            hash[sql] = scale
          end
          hash
        end

        options[:aggregated] = {}
        options[:aliases] = {}

        options[:select] = options[:select].inject([]) do |array, path|
          sql, sql_alias = ((path == ".*") ? "#{base_alias}.*" : path), nil

          if aggregate_method = (options[:aggregates] || {})[path]
            sql = select_aggregate_sql(aggregate_method, path)
            sql_alias = options[:aggregated][path] = select_aggregate_sql_alias(aggregate_method, path)
          end
          if scale = options[:scales][path]
            sql = "ROUND(#{sql}, #{scale})"
            sql_alias ||= quote_alias(path)
          end
          if options[:numerize_aliases]
            sql = sql.gsub(/ AS .*$/, "")
            sql_alias = options[:aliases][prepend_base_alias(sql_alias || sql)] = "c#{array.size + 1}"
          end
          unless sql_alias
            sql.match(/^(.*) AS (.*)$/)
            sql = $1 if $1
            sql_alias = $2
          end

          sql.gsub!(/sub:(\w+)\./) { "#{quote_alias($1)}." } if sql.is_a?(String)
          options[:aliases][sql] = sql_alias if sql_alias

          array << [sql, sql_alias].compact.join(" AS ")
          array
        end
      end

      def normalize_subselect!(options, original_options)
        options[:subselect] = options[:subselect].sort_by{|name, (klass, opts)| opts[:join] ? 0 : 1}.collect do |name, (klass, opts)|
          qry_options = original_options.deep_dup
          qry_options.reject!{|k, v| [:subselect, :numerize_aliases, :limit, :offset, :order_by, :join, :flatten].include?(k)}

          opts.each do |key, value|
            value = [value].flatten
            if key == :select
              qry_options[key] = value
            elsif [:join, :flatten].include?(key)
              # do nothing
            elsif key.to_s.match(/include_(\w+)/)
              (qry_options[$1.to_sym] || []).select!{|x| value.any?{|y| x.include?(y)}}
            elsif key.to_s.match(/exclude_(\w+)/)
              (qry_options[$1.to_sym] || []).reject!{|x| value.any?{|y| x.include?(y)}}
            else
              qry_options[key].concat value
            end
          end

          base_alias = quote_alias(klass.table_name.split("_").collect{|x| x[0]}.join(""))
          query_alias = quote_alias(name)

          if opts[:join] && !qry_options[:group_by].blank?
            joins = qry_options[:group_by].collect do |path|
              column = path.gsub(/\.\w+$/, "_id").strip
              column.match(/(.*) AS (\w+)$/)
              select_sql, select_alias = $1, $2
              qry_options[:select].unshift(column)
              "#{query_alias}.#{select_alias || column} = #{select_sql || "#{base_alias}.#{column}"}"
            end
            prefix = "LEFT JOIN\n   "
            postfix = " ON #{joins.join(" AND ")}"
          else
            prefix = " , "
          end

          query = klass.to_qry(qry_options).gsub(/\n\s*/, " ").gsub(/#{base_alias}[\s\.]/, "")

          if opts[:flatten]
            qry_alias = quote_alias("_#{name}")

            dup_options = qry_options.deep_dup
            normalize_select!(dup_options)
            prepend_base_alias!(dup_options)

            select = dup_options[:select].collect do |sql|
              sql_alias = sql.match(/ AS (.*?)$/).captures[0]
              "SUM(#{qry_alias}.#{sql_alias}) AS #{sql_alias}"
            end

            query = "SELECT #{select.join(", ")} FROM (#{query}) #{qry_alias}"
          end

          "#{prefix}(#{query}) #{query_alias}#{postfix}"

        end if options[:subselect]
      end

      def normalize_from!(options)
        options[:from] = "#{base.table_name} #{base_alias}"
      end

      def normalize_where!(options)
        regexp, aliases = /^\S+/, options[:aliases].invert

        where, having = (options[:where] || []).partition do |statement|
          !options[:aggregated].keys.include?(statement.strip.match(regexp).to_s) &&
          statement.gsub(/((?<![\\])['"])((?:.(?!(?<![\\])\1))*.?)\1/, " ")
                   .split(/\b(and|or)\b/i).reject{|sql| %w(and or).include? sql.downcase}
                   .collect{|sql| sql = sql.strip; (sql[0] == "(" && sql[-1] == ")" ? sql[1..-1] : sql)}
                   .all? do |sql|
            sql.match /(.*?)\s*(=|<=>|>=|>|<=|<|<>|!=|is|like|rlike|regexp|in|between|not|sounds|soundex)(\b|\s|$)/i
            path = $1.strip

            if (options[:aggregates] || {})[path]
              normalize_select!(opts = options.deep_dup.merge(:select => [path]))
              options[:select].concat(opts[:select]).uniq!
              options[:aggregated].merge!(opts[:aggregated])
              false
            else
              !(aliases[path] || path).match(/\b(count|sum|min|max|avg)\(/i)
            end
          end
        end

        unless (attrs = base.scope_attributes).blank?
          sql = base.send(:sanitize_sql_for_conditions, attrs, "").gsub(/``.`(\w+)`/) { $1 }
          where << sql
        end

        options[:where], options[:having] = where, having.collect do |statement|
          statement.strip.gsub(regexp){|path| options[:aggregated][path] || path}
        end

        [:where, :having].each do |key|
          if options[key].empty?
            options.delete key
          end
        end
      end

      def normalize_group_by!(options)
        options[:group_by].collect! do |x|
          if x.match(/^(.*?) AS (\w+)$/)
            if options[:select].any?{|x| x.include?("#{$1} AS ")}
              $1
            else
              options[:select] << x
              $2
            end
          else
            x
          end
        end if options[:group_by]
      end

      def normalize_order_by!(options)
        return unless options[:order_by]

        options[:order_by].collect! do |x|
          segments = x.split " "
          direction = segments.pop if %w(asc desc).include?(segments[-1].downcase)
          path = segments.join " "
          scale = options[:scales][path]

          select = begin
            if aggregate_method = (options[:aggregates] || {})[path]
              select_aggregate_sql(aggregate_method, path)
            else
              path
            end
          end

          "#{scale ? "ROUND(#{select}, #{scale})" : select} #{direction.upcase if direction}".strip
        end

        options[:order_by].compact!
      end

      def column_for(path)
        segments = path.split(".")
        column = segments.pop
        model = segments.inject(base) do |klass, association|
          klass.reflect_on_association(association.to_sym).klass
        end
        model.columns_hash[column]
      rescue
        nil
      end

      def parse_joins!(options)
        return if (paths = extract_paths(options)).empty?

        regexp = /INNER JOIN `([^`]+)`( `[^`]+`)? ON `[^`]+`.`([^`]+)` = `[^`]+`.`([^`]+)`/

        options[:joins] = paths.collect do |path|
          joins, associations = [], []
          path.split(".").inject(base) do |klass, association|
            association = association.to_sym

            table_joins = klass.joins(association).to_sql.scan regexp
            concerns_bridge_table = table_joins.size == 2
            bridge_table_as = nil

            table_joins.each_with_index do |table_join, index|
              concerns_bridge_table_join = concerns_bridge_table && index == 0
              join_table, possible_alias, join_table_column, table_column = table_join

              table_as = (klass == base) ? base_alias : quote_alias(associations.join(path_delimiter))
              join_table_as = quote_alias((associations + [association]).join(path_delimiter))

              if concerns_bridge_table
                if concerns_bridge_table_join
                  join_table_as = bridge_table_as = quote_alias("#{(associations + [association]).join(path_delimiter)}_bridge_table")
                else
                  table_as = bridge_table_as
                end
              end

              joins.push "LEFT JOIN #{join_table} #{join_table_as} ON #{join_table_as}.#{join_table_column} = #{table_as}.#{table_column}"
            end

            associations << association
            klass.reflect_on_association(association).klass
          end
          joins
        end.flatten.uniq.join("\n")
      end

      def extract_paths(options)
        [:select, :where, :group_by, :having, :order_by].inject([]) do |paths, key|
          if value = options[key]
            value = value.join " " if value.is_a?(Array)
            paths.concat value.gsub(/((?<![\\])['"])((?:.(?!(?<![\\])\1))*.?)\1/, " ").gsub(/sub:[a-zA-Z_]+\.[a-zA-Z_\.]+/, " ").scan(/[a-zA-Z_]+\.[a-zA-Z_\.]+/).collect{|x| x.split(".")[0..-2].join "."}
          else
            paths
          end
        end.uniq
      end

      def prepend_base_alias!(options)
        [:select, :where, :group_by, :having, :order_by].each do |key|
          if value = options[key]
            value.collect! do |sql|
              prepend_base_alias sql, options[:aliases]
            end
          end
        end
      end

      def prepend_base_alias(sql, aliases = {})
        return sql if sql.include?("SELECT")
        columns = base.columns_hash.keys
        sql.gsub(/("[^"]*"|'[^']*'|`[^`]*`|[a-zA-Z_#{aggregate_delimiter}]+(\.[a-zA-Z_\*]+)*)/) do
          columns.include?($1) ? "#{base_alias}.#{$1}" : begin
            if (string = $1).match /^([a-zA-Z_\.]+)\.([a-zA-Z_\*]+)$/
              path, column = $1, $2
              "#{quote_alias path.gsub(".", path_delimiter)}.#{column}"
            else
              string
            end
          end
        end
      end

      def finalize_options!(options); end

      def flatten_options!(options)
        options[:select] = if options[:select].size <= 3
          " " + options[:select].join(", ")
        else
          "\n  " + options[:select].join(",\n  ")
        end

        [:group_by, :order_by].each do |key|
          if value = options[key]
            options[key] = value.join(", ") if value.is_a?(Array)
          end
        end

        [:where, :having].each do |key|
          if value = options[key]
            options[key] = value.collect{|x| "(#{x})"}.join(" AND ") if value.is_a?(Array)
          end
        end
      end

      def compose_sql(options)
        sql = ["SELECT#{options[:select]}", "FROM #{options[:from]}", options[:joins], options[:subselect]].compact

        [:where, :group_by, :having, :order_by, :limit, :offset].each do |key|
          unless (value = options[key]).blank?
            keyword = key.to_s.upcase.gsub("_", " ")
            sql << "#{keyword} #{value}"
          end
        end

        sql.join "\n"
      end

    end
  end
end
