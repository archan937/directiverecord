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
              DirectiveRecord::Query.expects(:new).with(Office, Office.connection).returns(query)
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

          describe ".extract_connection" do
            describe "when specified" do
              it "returns the connection" do
                assert_equal "connection", Office.send(:extract_connection, ["id", "name", {:connection => "connection"}])
                assert_equal "connection", Office.send(:extract_connection, [{:connection => "connection"}])
              end
            end
            describe "when not specified" do
              it "returns the connection of the class" do
                Office.expects(:connection).returns(class_connection = "class_connection")
                assert_equal class_connection, Office.send(:extract_connection, ["id", "name"])
              end
            end
          end
        end

      end
    end
  end
end
