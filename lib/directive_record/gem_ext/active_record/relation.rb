module ActiveRecord
  class Relation

    def query_options(select = nil)
      DirectiveRecord::Relation.new(self).query_options(select)
    end

    def to_qry
      klass.to_qry query_options
    end

  end
end
