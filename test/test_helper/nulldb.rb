module ActiveRecord
  module ConnectionAdapters
    class NullDBAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter

      def quote_column_name(name)
        "`#{name.to_s.gsub('`', '``')}`"
      end

      def quote_table_name(name)
        quote_column_name(name).gsub('.', '`.`')
      end

      def columns(table_name, name = nil)
        if @tables.size <= 1
          ActiveRecord::Migration.verbose = false
          schema_path = if Pathname(@schema_path).absolute?
                          @schema_path
                        else
                          File.join(NullDB.configuration.project_root, @schema_path)
                        end
          Kernel.load(schema_path)
        end

        if table = @tables[table_name]
          table.columns.map do |col_def|
            ActiveRecord::ConnectionAdapters::NullDBAdapter::Column.new(
              col_def.name.to_s,
              col_def.default,
              col_def.type,
              col_def.null
            ).tap do |column|
              options = Hash[col_def.each_pair.to_a]
              [:precision, :scale].each do |key|
                column.instance_variable_set :"@#{key}", options[key]
              end
            end
          end
        else
          []
        end
      end

    end
  end
end
