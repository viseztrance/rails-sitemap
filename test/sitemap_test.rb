require "test/unit"
require "rubygems"
require "rails"
require "action_controller/railtie" # Rails 3.1
require "active_record"
require "nokogiri"

require File.expand_path("singleton", File.dirname(__FILE__))
require File.expand_path("setup", File.dirname(__FILE__))
require File.expand_path("../lib/sitemap", File.dirname(__FILE__))

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Activity < ActiveRecord::Base; end

class SitemapTest < Test::Unit::TestCase

  include SitemapTestSetup

  def setup
    create_db
    Sitemap::Generator.reset_instance
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

  def test_custom_collection_objects
    activities = [Activity.first, Activity.last]
    Sitemap::Generator.instance.render(:host => "someplace.com") do
      collection :activities, :objects => proc { activities }
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.length, activities.length
    activities.each_with_index do |activity, i|
      assert_equal elements[i].text, "http://someplace.com/activities/%d" % activity.id
    end
  end

  def test_params
    Sitemap::Generator.instance.render(:host => "someplace.com") do
      path :faq, :params => { :host => "anotherplace.com", :format => "html", :filter => "recent" }
      collection :activities, :params => { :host => proc { |obj| [obj.location, host].join(".") } }
    end
    activities = Activity.all
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.first.text, "http://anotherplace.com/questions.html?filter=recent"
    elements[1..-1].each_with_index do |element, i|
      assert_equal element.text, "http://%s.someplace.com/activities/%d" % [activities[i].location, activities[i].id]
    end
  end

  def test_search_attributes
    Sitemap::Generator.instance.render(:host => "someplace.com") do
      path :faq, :priority => 1, :change_frequency => "always"
      collection :activities, :change_frequency => "weekly"
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    assert_equal doc.xpath("//url/priority").first.text, "1"
    elements = doc.xpath "//url/changefreq"
    assert_equal elements[0].text, "always"
    elements[1..-1].each do |element|
      assert_equal element.text, "weekly"
    end
  end

  def test_file_url
    Sitemap::Generator.instance.render(:host => "someplace.com") {}
    assert_equal Sitemap::Generator.instance.file_url, "http://someplace.com/sitemap.xml"
  end

end
