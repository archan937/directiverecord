require_relative "../../test_helper"

module Unit
  module Query
    class TestMySQL < MiniTest::Test

      describe DirectiveRecord::Query::MySQL do
        before do
          DirectiveRecord::Query.expects(:class_for).returns(DirectiveRecord::Query::MySQL).at_least_once
        end

        it "generates the expected SQL" do
          assert_equal(
            strip(
              %Q{
                SELECT `o`.id, `o`.city
                FROM offices `o`
              }
            ),
            Office.to_qry("id, city")
          )

          assert_equal(
            strip(
              %Q{
                SELECT `e`.*
                FROM employees `e`
                WHERE (`e`.office_id = 1) AND (`e`.first_name LIKE '%y')
              }
            ),
            Employee.where("office_id = 1").where("first_name LIKE ?", "%y").to_qry
          )

          assert_equal(
            strip(
              %Q{
                SELECT `c`.id, `c`.name, COUNT(`orders`.id) AS order_count, GROUP_CONCAT(DISTINCT `tags`.name) AS tags
                FROM customers `c`
                LEFT JOIN orders `orders` ON `orders`.customer_id = `c`.id
                LEFT JOIN customers_tags `tags_bridge_table` ON `tags_bridge_table`.customer_id = `c`.id
                LEFT JOIN tags `tags` ON `tags`.id = `tags_bridge_table`.tag_id
              }
            ),
            Customer.to_qry("id, name, COUNT(orders.id) AS order_count, GROUP_CONCAT(DISTINCT tags.name) AS tags")
          )
        end
      end

    end
  end
end
