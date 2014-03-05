require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Generator" do

  before do
    create_db
    Sitemap.configuration.reset
    Sitemap::Generator.reset_instance
  end

  after do
    drop_db
  end

  it "should have a valid xml response" do
    Sitemap::Generator.instance.load(:host => "someplace.com") {}
    doc = Nokogiri::XML(Sitemap::Generator.instance.render)
    doc.errors.length.must_equal 0
    doc.root.name.must_equal "urlset"
  end

  it "should create entries based on literals" do
    urls = ["http://someplace.com/target_url", "http://someplace.com/another_url"]
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      literal "/target_url"
      literal "/another_url"
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal urls.length
    elements.each_with_index do |element, i|
      element.text.must_equal urls[i]
    end
  end

  it "should create entries based on literals with https" do
    urls = ["https://someplace.com/target_url", "https://someplace.com/another_url"]
    Sitemap::Generator.instance.load(:host => "someplace.com", :protocol => "https") do
      literal "/target_url"
      literal "/another_url"
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal urls.length
    elements.each_with_index do |element, i|
      element.text.must_equal urls[i]
    end
  end

  it "should create entries based on the route paths" do
    urls = ["http://someplace.com/", "http://someplace.com/questions"]
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :root
      path :faq
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal urls.length
    elements.each_with_index do |element, i|
      element.text.must_equal urls[i]
    end
  end

  it "should create entries based on the route paths with https" do
    urls = ["https://someplace.com/", "https://someplace.com/questions"]
    Sitemap::Generator.instance.load(:host => "someplace.com", :protocol => "https") do
      path :root
      path :faq
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal urls.length
    elements.each_with_index do |element, i|
      element.text.must_equal urls[i]
    end
  end

  it "should create entries based on the route resources" do
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal (Activity.count + 1)
    elements.first.text.must_equal "http://someplace.com/activities"
    elements[1..-1].each_with_index do |element, i|
      element.text.must_equal "http://someplace.com/activities/#{i + 1}"
    end
  end

  it "should create entries based on the route resources with https" do
    Sitemap::Generator.instance.load(:host => "someplace.com", :protocol => "https") do
      resources :activities
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal (Activity.count + 1)
    elements.first.text.must_equal "https://someplace.com/activities"
    elements[1..-1].each_with_index do |element, i|
      element.text.must_equal "https://someplace.com/activities/#{i + 1}"
    end
  end

  it "should create entries using only for the specified objects" do
    activities = proc { Activity.where(:published => true) }
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities, :objects => activities, :skip_index => true
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.length.must_equal activities.call.length
    activities.call.each_with_index do |activity, i|
      elements[i].text.must_equal "http://someplace.com/activities/%d" % activity.id
    end
  end

  it "should create urls using the specified params" do
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :faq, :params => { :host => "anotherplace.com", :format => "html", :filter => "recent" }
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.first.text.must_equal "http://anotherplace.com/questions.html?filter=recent"
  end

  it "should create params conditionaly by using a Proc" do
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities, :skip_index => true, :params => { :host => proc { |obj| [obj.location, host].join(".") } }
    end
    activities = Activity.all
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/loc"
    elements.each_with_index do |element, i|
      element.text.must_equal "http://%s.someplace.com/activities/%d" % [activities[i].location, activities[i].id]
    end
  end

  it "should add sitemap xml attributes" do
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :faq, :priority => 1, :change_frequency => "always"
      resources :activities, :change_frequency => "weekly"
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    doc.xpath("//url/priority").first.text.must_equal "1"
    elements = doc.xpath "//url/changefreq"
    elements[0].text.must_equal "always"
    elements[1..-1].each do |element|
      element.text.must_equal "weekly"
    end
  end

  it "should add sitemap xml attributes conditionaly by using a Proc" do
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities, :priority => proc { |obj| obj.id <= 2 ? 1 : 0.5 }, :skip_index => true
    end
    activities = Activity.all
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    elements = doc.xpath "//url/priority"
    elements.each_with_index do |element, i|
      value = activities[i].id <= 2 ? "1" : "0.5"
      element.text.must_equal value
    end
  end

  it "should discard empty (or false) search attributes" do
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      path :faq, :priority => "", :change_frequency => lambda { |e| return false}, :updated_at => Date.today
    end
    Sitemap::Generator.instance.build!
    doc = Nokogiri::HTML(Sitemap::Generator.instance.render)
    doc.xpath("//url/priority").count.must_equal 0
    doc.xpath("//url/changefreq").count.must_equal 0
    doc.xpath("//url/lastmod").text.must_equal Date.today.to_s
  end

  it "should set the sitemap url based on the current host" do
    Sitemap::Generator.instance.load(:host => "someplace.com") {}
    Sitemap::Generator.instance.file_url.must_equal "http://someplace.com/sitemap.xml"
  end

  it "should set the sitemap url based on the current host and context" do
    Sitemap::Generator.instance.load(:host => "someplace.com", :context => "foo/bar") {}
    Sitemap::Generator.instance.file_url.must_equal "http://someplace.com/foo/bar/sitemap.xml"
  end

  it "should create a file when saving" do
    path = File.join(Dir.tmpdir, "sitemap.xml")
    File.unlink(path) if File.exist?(path)
    Sitemap::Generator.instance.load(:host => "someplace.com") do
      resources :activities
    end
    Sitemap::Generator.instance.build!
    Sitemap::Generator.instance.save(path)
    File.exist?(path).must_equal true
    File.unlink(path)
  end

  describe "fragments" do

    before do
      Sitemap.configure do |config|
        config.max_urls = 2
      end
    end

    it "should save files" do
      Sitemap::Generator.instance.load(:host => "someplace.com") do
        path :root
        path :root
        path :root
        path :root
      end
      path = File.join(Dir.tmpdir, "sitemap.xml")
      root = File.join(Dir.tmpdir, "sitemaps") # Directory is being removed at the end of the test.
      File.directory?(root).must_equal false
      Sitemap::Generator.instance.build!
      Sitemap::Generator.instance.save(path)
      1.upto(2) { |i|
        File.exists?(File.join(root, "sitemap-fragment-#{i}.xml")).must_equal true
      }
      FileUtils.rm_rf(root)
    end

    it "should have an index page" do
      Sitemap::Generator.instance.load(:host => "someplace.com") do
        path :root
        path :root
        path :root
        path :root
        path :root
      end
      Sitemap::Generator.instance.build!
      doc = Nokogiri::HTML(Sitemap::Generator.instance.render("index"))
      elements = doc.xpath "//sitemap"
      Sitemap::Generator.instance.fragments.length.must_equal 3
    end

  end

end
