require_relative "../../../test_helper"

module Unit
  module GemExt
    module ActiveRecord
      class TestBase < MiniTest::Test

        describe ::ActiveRecord::Base do
          describe ".to_qry" do
            it "initiates a DirectiveRecord::Query instance and returns the query SQL" do
              query = mock
              query.expects(:to_sql).with(:select => "foo.bar").returns("SELECT foo.bar")
              DirectiveRecord::Query.expects(:new).with(Article).returns(query)
              assert_equal "SELECT foo.bar", Article.to_qry(:select => "foo.bar")
            end
          end

          describe ".qry" do
            it "selects rows with the generated query" do
              Article.expects(:to_qry).with("foo.bar").returns("<query>")
              Article.connection.expects(:select_rows).with("<query>").returns(%w(foo bar))
              assert_equal %w(foo bar), Article.qry("foo.bar")
            end
          end
        end

      end
    end
  end
end
