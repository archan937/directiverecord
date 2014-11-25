require_relative "../../../test_helper"

module Unit
  module GemExt
    module ActiveRecord
      class TestBase < MiniTest::Test

        describe ::ActiveRecord::Base do
          describe ".to_qry" do
            it "initiates a DirectiveRecord::Query instance and returns the query SQL" do
              query = mock
              query.expects(:to_sql).with(:select => "city").returns("SELECT city FROM offices")
              DirectiveRecord::Query.expects(:new).with(Office).returns(query)
              assert_equal "SELECT city FROM offices", Office.to_qry(:select => "city")
            end
          end

          describe ".qry" do
            it "selects rows with the generated query" do
              Office.expects(:to_qry).with("city").returns("SELECT city FROM offices")
              Office.connection.expects(:select_rows).with("SELECT city FROM offices").returns(%w(NYC))
              assert_equal %w(NYC), Office.qry("city")
            end
          end
        end

      end
    end
  end
end
