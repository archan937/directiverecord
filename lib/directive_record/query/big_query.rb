module DirectiveRecord
  module Query
    class BigQuery < SQL

    private

      def aggregate_delimiter
        "__"
      end

      def normalize_from!(options)
        period = options[:period]

        options[:where].delete_if do |statement|
          if statement.match(/^#{period} = '(\d{4}-\d{2}-\d{2})'$/)
            begin_date, end_date = $1, $1
          elsif statement.match(/^#{period} >= '(\d{4}-\d{2}-\d{2})' AND #{period} <= '(\d{4}-\d{2}-\d{2})'$/)
            begin_date, end_date = $1, $2
          end
          if begin_date
            options[:from] = "\n  TABLE_DATE_RANGE(#{options[:dataset]}.#{base.table_name}_, TIMESTAMP('#{begin_date}'), TIMESTAMP('#{end_date}'))"
          end
        end
      end

      def prepend_base_alias!(options); end

      def finalize_options!(options)
        aliases = options[:aliases] || {}

        options[:select].collect! do |string|
          if string.match(/^(.*) AS (.*)$/)
            select_expression, select_alias = $1, $2
            aliases[select_expression] = select_alias
          end

          select_expression ||= string
          group_by_expression = select_alias || string

          if options[:group_by].include?(group_by_expression) || options[:group_by].include?(select_expression) || !select_expression.match(/^\w+(\.\w+)*$/)
            string
          else
            ["MAX(#{select_expression})", select_alias].compact.join(" AS ")
          end
        end if options[:group_by]

        {", " => [:group_by, :order_by], " AND " => [:having]}.each do |delimiter, keys|
          keys.each do |key|
            if value = options[key]
              value = value.join delimiter
              aliases.each{|pattern, replacement| value.gsub! /(?=^|\b|\s)#{Regexp.escape pattern}(?=\b|\s|$)/, replacement}
              options[key] = value
            end
          end
        end
      end

    end
  end
end
