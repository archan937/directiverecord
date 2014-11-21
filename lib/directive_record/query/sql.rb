module DirectiveRecord
  module Query
    class SQL

      delegate :columns_hash, :to => :base

      def initialize(base)
        @base = base
      end

      def to_sql(options)
        options.assert_valid_keys :select, :numerize_aliases, :where, :group_by, :order_by, :limit, :offset, :aggregates
        options[:select] ||= "*"
        options = finalize_options options

        select, where, having, group_by, order_by = [:select, :where, :having, :group_by, :order_by].collect do |sym|
          if value = options[sym]
            prepend_base_alias value, options[:aliases]
          end
        end

        paths = extract_paths options
        joins = parse_joins(paths).join("\n") if paths.any?

        sql = []
        sql << "SELECT #{select}"
        sql << "FROM #{base.table_name} #{base_alias}"
        sql << joins if joins
        sql << "WHERE #{where}" if where
        sql << "GROUP BY #{group_by}" if group_by
        sql << "HAVING #{having}" if having
        sql << "ORDER BY #{order_by}" if order_by
        sql << "LIMIT #{options[:limit]}" if options[:limit]
        sql << "OFFSET #{options[:offset]}" if options[:offset]
        sql.join("\n")
      end

    private

      def base
        @base
      end

      def base_alias
        @base_alias ||= quote_alias(base.table_name.split("_").collect{|x| x[0]}.join(""))
      end

      def quote_alias(sql_alias)
        sql_alias
      end

      def prepend_base_alias(sql, aliases = {})
        columns = columns_hash.keys
        sql = sql.join ", " if sql.is_a?(Array)
        sql.gsub(/("[^"]*"|'[^']*'|[a-zA-Z_]+(\.[a-zA-Z_]+)*)/) do
          columns.include?($1) ? "#{base_alias}.#{$1}" : begin
            if (string = $1).match /^([a-zA-Z_\.]+)\.([a-zA-Z_]+)$/
              path, column = $1, $2
              "#{quote_alias path.gsub(".", "__")}.#{column}"
            else
              string
            end
          end
        end
      end

      def finalize_options(options)
        raise NotImplementedError
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

      def extract_paths(options)
        options.inject([]) do |paths, (key, value)|
          if [:select, :where, :group_by, :having].include?(key)
            value = value.join " " if value.is_a?(Array)
            paths.concat value.gsub(/((?<![\\])['"])((?:.(?!(?<![\\])\1))*.?)\1/, " ").scan(/[a-zA-Z_]+\.[a-zA-Z_\.]+/).collect{|x| x.split(".")[0..-2].join "."}
          else
            paths
          end
        end.uniq
      end

      def parse_joins(paths)
        regexp = /INNER JOIN `([^`]+)`( `[^`]+`)? ON `[^`]+`.`([^`]+)` = `[^`]+`.`([^`]+)`/

        paths.collect do |path|
          joins, associations = [], []
          path.split(".").inject(base) do |klass, association|
            association = association.to_sym

            table_joins = klass.joins(association).to_sql.scan regexp
            concerns_bridge_table = table_joins.size == 2
            bridge_table_as = nil

            table_joins.each_with_index do |table_join, index|
              concerns_bridge_table_join = concerns_bridge_table && index == 0
              join_table, possible_alias, join_table_column, table_column = table_join

              table_as = (klass == base) ? base_alias : quote_alias(associations.join("__"))
              join_table_as = quote_alias((associations + [association]).join("__"))

              if concerns_bridge_table
                if concerns_bridge_table_join
                  join_table_as = bridge_table_as = quote_alias("#{(associations + [association]).join("__")}_bridge_table")
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
        end.flatten.uniq
      end

    end
  end
end
