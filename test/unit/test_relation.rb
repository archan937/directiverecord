require_relative "../test_helper"

module Unit
  class TestQuery < MiniTest::Test

    describe DirectiveRecord::Relation do
      describe "#initialize" do
        it "stores the passed active relation as an instance variable" do
          directive_relation = DirectiveRecord::Relation.new(active_relation = mock)
          assert_equal active_relation, directive_relation.instance_variable_get(:@active_relation)
        end
      end

      describe "#qry_options" do
        it "returns the expected options" do
          assert_equal({
            :select => "city",
            :where => ["id = 1"]
          }, Office.where(:id => 1).qry_options("city"))

          assert_equal({
            :where => ["employees.first_name LIKE '%y'"]
          }, Office.where("employees.first_name LIKE ?", "%y").qry_options)

          assert_equal({
            :select => ["id, city"],
            :where => ["employees.first_name LIKE '%y'"],
            :group_by => ["id"],
            :order_by => ["city"]
          }, Office.select("id, city").where("employees.first_name LIKE ?", "%y").group("id").order("city").qry_options)

          assert_equal({
            :where => ["sales_rep_employee.office.city LIKE '%on'"]
          }, Customer.where("sales_rep_employee.office.city LIKE ?", "%on").qry_options)
        end
      end
    end

  end
end
