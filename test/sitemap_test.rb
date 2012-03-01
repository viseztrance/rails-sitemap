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
    Sitemap::Generator.instance.load(:host => "someplace.com") {}
    doc = Nokogiri::XML(Sitemap::Generator.instance.build)
    assert doc.errors.empty?
    assert_equal doc.root.name, "urlset"
  end

  def test_path_route
    urls = ["http://someplace.com/", "http://someplace.com/questions"]
    Sitemap::Generator.instance.load(:host => "someplace.com") do
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

  def test_resources_route
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.length, Activity.count + 1
    assert_equal elements.first.text, "http://someplace.com/activities"
    elements[1..-1].each_with_index do |element, i|
      assert_equal element.text, "http://someplace.com/activities/#{i + 1}"
    end
  end

  def test_custom_resource_objects
    activities = proc { Activity.where(:published => true) }
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities, :objects => activities, :skip_index => true
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.length, activities.call.length
    activities.call.each_with_index do |activity, i|
      assert_equal elements[i].text, "http://someplace.com/activities/%d" % activity.id
    end
  end

  def test_params_options
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :faq, :params => { :host => "anotherplace.com", :format => "html", :filter => "recent" }
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    assert_equal elements.first.text, "http://anotherplace.com/questions.html?filter=recent"
  end

  def test_params_blocks
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities, :skip_index => true, :params => { :host => proc { |obj| [obj.location, host].join(".") } }
    end
    activities = Activity.all
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/loc"
    elements.each_with_index do |element, i|
      assert_equal element.text, "http://%s.someplace.com/activities/%d" % [activities[i].location, activities[i].id]
    end
  end

  def test_search_attribute_options
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :faq, :priority => 1, :change_frequency => "always"
      resources :activities, :change_frequency => "weekly"
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    assert_equal doc.xpath("//url/priority").first.text, "1"
    elements = doc.xpath "//url/changefreq"
    assert_equal elements[0].text, "always"
    elements[1..-1].each do |element|
      assert_equal element.text, "weekly"
    end
  end

  def test_search_attribute_blocks
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities, :priority => proc { |obj| obj.id <= 2 ? 1 : 0.5 }, :skip_index => true
    end
    activities = Activity.all
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    elements = doc.xpath "//url/priority"
    elements.each_with_index do |element, i|
      value = activities[i].id <= 2 ? "1" : "0.5"
      assert_equal element.text, value
    end
  end

  def test_discards_empty_search_attributes # Empty or false (boolean).
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :faq, :priority => "", :change_frequency => lambda { |e| return false}, :updated_at => Date.today
    end
    doc = Nokogiri::HTML(Sitemap::Generator.instance.build)
    assert_equal doc.xpath("//url/priority").count, 0
    assert_equal doc.xpath("//url/changefreq").count, 0
    assert_equal doc.xpath("//url/lastmod").text, Date.today.to_s
  end

  def test_file_url
    Sitemap::Generator.instance.load(:host => "someplace.com") {}
    assert_equal Sitemap::Generator.instance.file_url, "http://someplace.com/sitemap.xml"
  end

  def test_save_creates_file
    path = File.join(Dir.tmpdir, "sitemap.xml")
    File.unlink(path) if File.exist?(path)
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities
    end
    doc = Nokogiri::XML(Sitemap::Generator.instance.build)
    Sitemap::Generator.instance.save("/tmp/sitemap.xml")
    assert File.exist?(path)
    File.unlink(path)
  end

end
