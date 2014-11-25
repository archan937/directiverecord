module DirectiveRecord
  module Query
    class MonetDB < SQL

    private

      def path_delimiter
        "__"
      end

      def aggregate_delimiter
        "__"
      end

      def group_by_all_sql
        "all_rows"
      end

      def prepare_options!(options)
        normalize_group_by! options
        [:select, :where, :having, :group_by, :order_by].each do |key|
          if options[key]
            base.reflections.keys.each do |association|
              options[key] = [options[key]].flatten.collect{|x| x.gsub(/^#{association}\.([a-z_\.]+)/) { "#{association}_#{$1.gsub(".", "_")}" }}
            end
          end
        end
      end

      def finalize_options!(options)
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

        options[:select] = options[:select].split(", ").collect do |string|
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
