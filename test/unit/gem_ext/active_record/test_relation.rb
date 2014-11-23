require_relative "../../../test_helper"

module Unit
  module GemExt
    module ActiveRecord
      class TestRelation < MiniTest::Test

        describe ::ActiveRecord::Relation do
          before do
            @relation = Article.where(:id => 1)
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
              @relation.expects(:qry_options).with("foo.bar").returns(:foo => "bar")
              Article.expects(:to_qry).with(:foo => "bar").returns("<query>")
              assert_equal "<query>", @relation.to_qry("foo.bar")
            end
          end

          describe "#qry" do
            it "delegates to its klass with qry_options" do
              @relation.expects(:qry_options).with("foo.bar").returns(:foo => "bar")
              Article.expects(:qry).with(:foo => "bar").returns(%w(foo bar))
              assert_equal %w(foo bar), @relation.qry("foo.bar")
            end
          end
        end

      end
    end
  end
end
