module ActiveRecord
  class Relation

    alias :original_count :count

    def count(column_name = nil, options = {})
      if !loaded? && (column_name == :all) && (options == {})
        associations = klass.reflections.keys.collect(&:to_s)

        contains_possible_paths = qry_options.any? do |key, value|
          if value.is_a?(Array)
            value.any? do |val|
              val.to_s.scan(/(?:^|[^\.])([a-z_]+)\.[a-z_]+/).flatten.any? do |string|
                associations.include?(string)
              end
            end
          end
        end

        if contains_possible_paths
          return qry("COUNT(DISTINCT id)")[0][0]
        end
      end
      original_count column_name, options
    end

  end
end
