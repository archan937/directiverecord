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
            Employee.where(:office_id => 1).where(Employee.arel_table[:first_name].matches("%y")).to_qry
          )

          assert_equal(
            strip(
              %Q{
                SELECT `e`.*
                FROM employees `e`
                WHERE ((`e`.office_id = 1) AND (`e`.first_name LIKE '%y'))
              }
            ),
            Employee.where("(office_id = 1) AND (first_name LIKE '%y')").to_qry
          )

          assert_equal(
            strip(
              %Q{
                SELECT `c`.id, `c`.name, COUNT(`orders`.id) AS order_count, GROUP_CONCAT(DISTINCT `tags`.name) AS tags
                FROM customers `c`
                LEFT JOIN orders `orders` ON `orders`.customer_id = `c`.id
                LEFT JOIN customers_tags `tags_bridge_table` ON `tags_bridge_table`.customer_id = `c`.id
                LEFT JOIN tags `tags` ON `tags`.id = `tags_bridge_table`.tag_id
                GROUP BY `c`.id
                ORDER BY COUNT(DISTINCT `tags`.id) DESC
                LIMIT 5
              }
            ),
            Customer.to_qry("id, name, COUNT(orders.id) AS order_count, GROUP_CONCAT(DISTINCT tags.name) AS tags", :group_by => "id", :order_by => "COUNT(DISTINCT tags.id) DESC", :limit => 5)
          )

          assert_equal(
            strip(
              %Q{
                SELECT `c`.*
                FROM customers `c`
                LEFT JOIN customers_tags `tags_bridge_table` ON `tags_bridge_table`.customer_id = `c`.id
                LEFT JOIN tags `tags` ON `tags`.id = `tags_bridge_table`.tag_id
                WHERE (`tags`.name LIKE '%gifts%')
              }
            ),
            Customer.where("tags.name LIKE ?", "%gifts%").to_qry
          )

          assert_equal(
            strip(
              %Q{
                SELECT `tags`.*
                FROM customers `c`
                LEFT JOIN customers_tags `tags_bridge_table` ON `tags_bridge_table`.customer_id = `c`.id
                LEFT JOIN tags `tags` ON `tags`.id = `tags_bridge_table`.tag_id
                WHERE (`tags`.name LIKE '%gifts%')
                GROUP BY `tags`.id
                ORDER BY `tags`.id
              }
            ),
            Customer.where("tags.name LIKE ?", "%gifts%").group("tags.id").to_qry("tags.*")
          )

          assert_equal(
            strip(
              %Q{
                SELECT `c`.id, `c`.name, COUNT(`orders`.id) AS order_count
                FROM customers `c`
                LEFT JOIN orders `orders` ON `orders`.customer_id = `c`.id
                GROUP BY `c`.id
                HAVING (order_count > 3)
                ORDER BY `c`.id
              }
            ),
            Customer.to_qry("id, name, COUNT(orders.id) AS order_count", :where => "order_count > 3", :group_by => "id")
          )

          $default_office_scope = {:id => [1, 3, 6]}

          assert_equal(
            strip(
              %Q{
                SELECT `o`.id AS c1, `o`.city AS c2
                FROM offices `o`
                WHERE (`o`.id IN (1, 3, 6))
              }
            ),
            Office.to_qry("id", "city", :numerize_aliases => true)
          )

          $default_office_scope = nil

          assert_equal(
            strip(
              %Q{
                SELECT `o`.id AS c1, `o`.city AS c2
                FROM offices `o`
              }
            ),
            Office.to_qry("id", "city", :numerize_aliases => true)
          )

          assert_equal(
            strip(
              %Q{
                SELECT `c`.id, `c`.name, MAX(`orders`.order_date) AS `max:orders.order_date`
                FROM customers `c`
                LEFT JOIN orders `orders` ON `orders`.customer_id = `c`.id
              }
            ),
            Customer.to_qry("id", "name", "orders.order_date", :aggregates => {"orders.order_date" => :max})
          )

          assert_equal(
            strip(
              %Q{
                SELECT `c`.id, `c`.name, MAX(`orders`.order_date) AS `max:orders.order_date`
                FROM customers `c`
                LEFT JOIN orders `orders` ON `orders`.customer_id = `c`.id
                ORDER BY MAX(`orders`.order_date)
              }
            ),
            Customer.to_qry("id", "name", "orders.order_date", :aggregates => {"orders.order_date" => :max}, :order_by => "orders.order_date")
          )

          assert_equal(
            strip(
              %Q{
                SELECT ROUND(SUM(`od`.price_each), 2) AS `sum:price_each`
                FROM order_details `od`
                GROUP BY NULL
              }
            ),
            OrderDetail.to_qry("price_each", :aggregates => {"price_each" => :sum}, :group_by => :all)
          )

          assert_equal(
            strip(
              %Q{
                SELECT ROUND(SUM(`od`.price_each), 2) AS `sum:price_each`
                FROM order_details `od`
                GROUP BY `od`.order_id
                ORDER BY `od`.order_id
              }
            ),
            OrderDetail.to_qry("price_each", :aggregates => {"price_each" => :sum}, :group_by => "order_id")
          )

          assert_equal(
            strip(
              %Q{
                SELECT `order`.id AS c1, ROUND(SUM(`od`.price_each), 2) AS c2
                FROM order_details `od`
                LEFT JOIN orders `order` ON `order`.id = `od`.order_id
                GROUP BY c1
                ORDER BY c1
              }
            ),
            OrderDetail.to_qry("order.id", "price_each", :aggregates => {"price_each" => :sum}, :group_by => "order.id", :numerize_aliases => true)
          )

          assert_equal(
            strip(
              %Q{
                SELECT `e`.*
                FROM employees `e`
                WHERE (`e`.first_name LIKE '%y')
              }
            ),
            Employee.where(["first_name LIKE ?", "%y"]).to_qry
          )

          assert_equal(
            strip(
              %Q{
                SELECT `o`.*
                FROM offices `o`
                WHERE (`o`.country = 'USA')
              }
            ),
            Office.usa.to_qry
          )
        end
      end

    end
  end
end
