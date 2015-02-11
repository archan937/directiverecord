require_relative "../../test_helper"

module Unit
  module Query
    class TestSQL < MiniTest::Test

      describe DirectiveRecord::Query::SQL do
        before do
          @base = mock
          @directive_query = DirectiveRecord::Query::SQL.new(@base)
        end

        describe "#initialize" do
          it "stores the passed base class as an instance variable" do
            assert_equal @base, @directive_query.instance_variable_get(:@base)
          end
        end

        describe "#path_delimiter" do
          it "returns nil" do
            assert_nil @directive_query.send(:path_delimiter)
          end
        end

        describe "#aggregate_delimiter" do
          it "raises an NotImplementedError" do
            assert_raises NotImplementedError do
              @directive_query.send :aggregate_delimiter
            end
          end
        end
      end

    end
  end
end
