module ActiveRecord
  class Relation

    def qry_options(select = nil)
      DirectiveRecord::Relation.new(self).qry_options(select)
    end

    def to_qry(select = nil)
      klass.to_qry qry_options(select)
    end

    def qry(select = nil)
      klass.qry qry_options(select)
    end

  end
end
