require_relative "../test_helper"

module Unit
  class TestDirectiveRecord < MiniTest::Test

    describe DirectiveRecord do
      it "has the current version" do
        version = File.read(project_file("VERSION")).strip
        assert_equal version, DirectiveRecord::VERSION
        assert File.read(project_file("CHANGELOG.rdoc")).include?("Version #{version} ")
      end
    end

  end
end
