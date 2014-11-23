require_relative "../test_helper"

module Unit
  class TestQuery < MiniTest::Test

    describe DirectiveRecord::Query do
      describe ".new" do
        it "returns the appropriate query instance" do
          instance = mock
          instance.expects(:new).with(Article).returns("<query instance>")
          DirectiveRecord::Query.expects(:class_for).with("activerecord::connectionadapters::mysql2adapter").returns(instance)
          assert_equal "<query instance>", DirectiveRecord::Query.new(Article)
        end
      end

      describe ".class_for" do
        describe "when MySQL" do
          it "returns the DirectiveRecord::Query::MySQL class" do
            assert_equal DirectiveRecord::Query::MySQL, DirectiveRecord::Query.send(:class_for, "activerecord::mysql::connection")
          end
        end

        describe "when MonetDB" do
          it "returns the DirectiveRecord::Query::MonetDB class" do
            assert_equal DirectiveRecord::Query::MonetDB, DirectiveRecord::Query.send(:class_for, "monetdb::connection")
          end
        end

        describe "when else" do
          it "raises a NotImplementedError" do
            assert_raises NotImplementedError do
              DirectiveRecord::Query.send(:class_for, "foobar::connection")
            end
          end
        end
      end
    end

  end
end
