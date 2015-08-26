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

      def quote_alias(sql_alias)
        "`#{sql_alias}`"
      end

      def finalize_options!(options)
        return unless options[:numerize_aliases]

        aliases = options[:aliases] || {}

        [:group_by, :having, :order_by].each do |key|
          if value = options[key]
            value = value.join ", "
            aliases.each{|pattern, replacement| value.gsub! /(?=^|\b|\s)#{Regexp.escape pattern}(?=\b|\s|$)/, replacement}
            options[key] = value
          end
        end
      end

    end
  end
end
