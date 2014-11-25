require_relative "../../../test_helper"

module Unit
  module GemExt
    module ActiveRecord
      class TestRelation < MiniTest::Test

        describe ::ActiveRecord::Relation do
          before do
            @relation = Office.where(:id => 1)
          end

          describe "#qry_options" do
            it "initiates a DirectiveRecord::Relation instance and returns the query options" do
              relation = mock
              relation.expects(:qry_options).returns(:where => "id = 1")
              DirectiveRecord::Relation.expects(:new).with(@relation).returns(relation)
              assert_equal({:where => "id = 1"}, @relation.qry_options)
            end
          end

          describe "#to_qry" do
            it "delegates to its klass with qry_options" do
              @relation.expects(:qry_options).with("city").returns(:select => "city", :where => ["id = 1"])
              Office.expects(:to_qry).with(:select => "city", :where => ["id = 1"]).returns("SELECT city FROM offices WHERE id = 1")
              assert_equal "SELECT city FROM offices WHERE id = 1", @relation.to_qry("city")
            end
          end

          describe "#qry" do
            it "delegates to its klass with qry_options" do
              @relation.expects(:qry_options).with("city").returns(:select => "city", :where => ["id = 1"])
              Office.expects(:qry).with(:select => "city", :where => ["id = 1"]).returns(%w(NYC))
              assert_equal %w(NYC), @relation.qry("city")
            end
          end
        end

      end
    end
  end
end
