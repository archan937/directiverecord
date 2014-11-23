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
            :select => "title",
            :where => ["id = 1"]
          }, Article.where(:id => 1).qry_options("title"))

          assert_equal({
            :where => ["tags.name LIKE '%ruby%'"]
          }, Article.where("tags.name LIKE ?", "%ruby%").qry_options)

          assert_equal({
            :select => ["id, title"],
            :where => ["title LIKE '%behold%'"],
            :group_by => ["id"],
            :order_by => ["title"]
          }, Article.select("id, title").where("title LIKE ?", "%behold%").group("id").order("title").qry_options)

          assert_equal({
            :where => ["author.foo.title LIKE '%ruby%'"]
          }, Article.where("author.foo.title LIKE ?", "%ruby%").qry_options)
        end
      end
    end

  end
end
