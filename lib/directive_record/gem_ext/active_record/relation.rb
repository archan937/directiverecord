module ActiveRecord
  class Relation

    def qry_options(*args)
      DirectiveRecord::Relation.new(self).qry_options(*args)
    end

    def to_qry(*args)
      klass.to_qry qry_options(*args)
    end

    def qry(*args)
      klass.qry qry_options(*args)
    end

    alias :original_count :count

    def count(column_name = nil, options = {})
      if !loaded? && (column_name == :all) && (options == {})
        qry("COUNT(DISTINCT id)")[0][0]
      else
        original_count column_name, options
      end
    end

  end
end
