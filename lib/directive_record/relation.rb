module DirectiveRecord
  class Relation

    delegate :connection, :klass, :select_values, :where_values, :group_values, :order_values, :limit_value, :offset_value, :bind_values, :joins_values, :to => :@active_relation

    def initialize(active_relation)
      @active_relation = active_relation
    end

    def query_options(select = nil)
      {
        :select => select || select_values.collect{|x| sql_aliases_to_paths(x)},
        :where => where_values.collect{|x| sql_aliases_to_paths(x)},
        :group_by => group_values.collect{|x| sql_aliases_to_paths(x)},
        :order_by => order_values.collect{|x| sql_aliases_to_paths(x)},
        :limit => limit_value,
        :offset => offset_value
      }.reject!{|k, v| v.blank?}
    end

  private

    def sql_aliases_to_paths(arg)
      visit_sql(arg).gsub(/(`([^`]+)`\.`([^`]+)`)/) do
        sql_alias, column = $2, $3
        path = sql_alias_to_path sql_alias
        path.empty? ? column : "#{path}.#{column}"
      end
    end

    def visit_sql(arg)
      return arg if arg.is_a?(String)
      binds = bind_values.dup
      connection.visitor.accept(arg) do
        connection.quote(*binds.shift.reverse)
      end
    end

    def sql_alias_to_path(sql_alias)
      sql_alias_to_association(sql_alias, klass) || begin
        chain, joins_sql = [sql_alias], joins_values.collect(&:to_sql)
        regexp = /INNER JOIN `([^`]+)` ?`?([^`]+)?`? ON `([^`]+)`.`[^`]+` = `([^`]+)`.`[^`]+`/

        while match = joins_sql.detect{|x| x.match(regexp) && (($2 || $1) == sql_alias)}
          joins_sql.delete(match)
          sql_alias = [$3, $4].detect{|x| x != sql_alias}
          chain.unshift sql_alias
        end

        path = []
        chain[1..-1].inject(klass) do |klass, sql_alias|
          path << sql_alias_to_association(sql_alias, klass)
          klass.reflect_on_association(path[-1].to_sym).klass
        end
        path.join "."
      end
    end

    def sql_alias_to_association(sql_alias, klass)
      return "" if sql_alias == klass.table_name
      regexp = /INNER JOIN `([^`]+)` ?`?([^`]+)?`? ON/
      klass.reflections.keys.collect(&:to_s).detect{|x| klass.joins(x.to_sym).to_sql.match(regexp) && (($2 || $1) == sql_alias)}
    end

  end
end
