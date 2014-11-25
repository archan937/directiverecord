require_relative "../../test_helper"

module Unit
  module Query
    class TestMonetDB < MiniTest::Test

      describe DirectiveRecord::Query::MonetDB do
        before do
          DirectiveRecord::Query.expects(:class_for).returns(DirectiveRecord::Query::MonetDB).at_least_once
        end

        it "generates the expected SQL" do
          assert_equal(
            strip(
              %Q{
                SELECT o.id, o.city
                FROM offices o
              }
            ),
            Office.to_qry("id, city")
          )
        end
      end

    end
  end
end
