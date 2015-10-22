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

    def qry_value(*args)
      klass.qry_value qry_options(*args)
    end

    def qry_values(*args)
      klass.qry_values qry_options(*args)
    end

  end
end
