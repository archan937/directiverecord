require_relative "../../test_helper"

module Google
  class BigQuery
  end
end

module Unit
  module Query
    class TestBigQuery < MiniTest::Test

      describe DirectiveRecord::Query::BigQuery do
        before do
          connection = Google::BigQuery.new
          Google::BigQuery.expects(:connection).returns(connection).at_least_once
        end

        it "generates the expected SQL" do
          assert_equal(
            %Q{
              SELECT id,
                     SUM(order_details_quantity_ordered) AS sum__order_details_quantity_ordered,
                     SUM(order_details_price_each) AS sum__order_details_price_each,
                     SUM(order_details_quantity_ordered * order_details_price_each) AS price
              FROM
                TABLE_DATE_RANGE(my_stats.orders_, TIMESTAMP('2015-01-21'), TIMESTAMP('2015-01-21'))
              GROUP BY id
              ORDER BY price DESC
            }.strip.gsub(/\s+/, " "),
            Order.to_qry(
              "id", "order_details_quantity_ordered", "order_details_price_each", "SUM(order_details_quantity_ordered * order_details_price_each) AS price",
              :connection => Google::BigQuery.connection,
              :where => "order_date = '2015-01-21'",
              :group_by => "id",
              :order_by => "price DESC",
              :dataset => "my_stats",
              :period => "order_date",
              :aggregates => {
                "order_details_quantity_ordered" => :sum,
                "order_details_price_each" => :sum
              }
            ).strip.gsub(/\s+/, " ")
          )

          assert_equal(
            %Q{
              SELECT id, SUM(order_details_quantity_ordered * order_details_price_each)
              FROM
                TABLE_DATE_RANGE(my_stats.orders_, TIMESTAMP('2015-01-15'), TIMESTAMP('2015-01-21'))
              GROUP BY id
              ORDER BY id
            }.strip.gsub(/\s+/, " "),
            Order.to_qry(
              "id", "SUM(order_details.quantity_ordered * order_details.price_each)",
              :connection => Google::BigQuery.connection,
              :where => "order_date >= '2015-01-15' AND order_date <= '2015-01-21'",
              :group_by => "id",
              :order_by => "id",
              :dataset => "my_stats",
              :period => "order_date"
            ).strip.gsub(/\s+/, " ")
          )

          assert_equal(
            %Q{
              SELECT id, MAX(customer_id), SUM(order_details_quantity_ordered * order_details_price_each)
              FROM
                TABLE_DATE_RANGE(my_stats.orders_, TIMESTAMP('2015-01-15'), TIMESTAMP('2015-01-21'))
              GROUP BY id
              ORDER BY id
            }.strip.gsub(/\s+/, " "),
            Order.to_qry(
              "id", "customer_id", "SUM(order_details.quantity_ordered * order_details.price_each)",
              :connection => Google::BigQuery.connection,
              :where => "order_date >= '2015-01-15' AND order_date <= '2015-01-21'",
              :group_by => "id",
              :order_by => "id",
              :dataset => "my_stats",
              :period => "order_date"
            ).strip.gsub(/\s+/, " ")
          )

          assert_equal(
            %Q{
              SELECT COUNT(id), YEAR(order_date) AS year
              FROM
                TABLE_DATE_RANGE(my_stats.orders_, TIMESTAMP('2015-01-15'), TIMESTAMP('2015-01-21'))
              GROUP BY year
            }.strip.gsub(/\s+/, " "),
            Order.to_qry(
              "COUNT(id)",
              :connection => Google::BigQuery.connection,
              :where => "order_date >= '2015-01-15' AND order_date <= '2015-01-21'",
              :group_by => "YEAR(order_date) AS year",
              :dataset => "my_stats",
              :period => "order_date"
            ).strip.gsub(/\s+/, " ")
          )
        end
      end

    end
  end
end
