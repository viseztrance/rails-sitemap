require "test/unit"
require "rubygems"
require "rails"
require "action_controller/railtie" # Rails 3.1
require "active_record"
require "nokogiri"

require File.expand_path("setup", File.dirname(__FILE__))
require File.expand_path("../lib/sitemap", File.dirname(__FILE__))

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Activity < ActiveRecord::Base
end

class SitemapTest < Test::Unit::TestCase

  include SitemapTestSetup

  def setup
    create_db
    Sitemap::Generator.instance.entries = []
  end

  def teardown
    drop_db
  end

  def test_xml_response
    Sitemap::Generator.instance.render(:host => "someplace.com") {}
    doc = Nokogiri::XML(Sitemap::Generator.instance.build)
    assert doc.errors.empty?
    assert_equal doc.root.name, "urlset"
  end

  def test_path_route
    urls = ["http://someplace.com/", "http://someplace.com/questions"]
    Sitemap::Generator.instance.render(:host => "someplace.com") do
      path :root
      path :faq
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.length, urls.length
    elements.each_with_index do |element, i|
      assert_equal element.text, urls[i]
    end
  end

  def test_collections_route
    Sitemap::Generator.instance.render(:host => "someplace.com") do
      collection :activities
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.length, Activity.count
    elements.each_with_index do |element, i|
      assert_equal element.text, "http://someplace.com/activities/#{i + 1}"
    end
  end

end
