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

    alias :original_size :size

    def size
      loaded? ? original_size : qry("COUNT(*)")[0][0]
    end

  end
end
