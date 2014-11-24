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
                SELECT `a`.id, `a`.title
                FROM articles `a`
              }
            ),
            Article.to_qry("id, title")
          )

          assert_equal(
            strip(
              %Q{
                SELECT *
                FROM articles `a`
                WHERE (`a`.id > 0) AND (`a`.title LIKE 'Behold%')
              }
            ),
            Article.where("id > 0").where("title LIKE ?", "Behold%").to_qry
          )

          assert_equal(
            strip(
              %Q{
                SELECT `a`.id, `a`.title, `author`.name, GROUP_CONCAT(`tags`.name)
                FROM articles `a`
                LEFT JOIN users `author` ON `author`.id = `a`.author_id
                LEFT JOIN articles_tags `tags_bridge_table` ON `tags_bridge_table`.article_id = `a`.id
                LEFT JOIN tags `tags` ON `tags`.id = `tags_bridge_table`.tag_id
              }
            ),
            Article.to_qry("id, title, author.name, GROUP_CONCAT(tags.name)")
          )
        end
      end

    end
  end
end
