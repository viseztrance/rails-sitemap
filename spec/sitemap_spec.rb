require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Sitemap" do

  it "should have a configuration" do
    Sitemap.configuration.must_be_instance_of Sitemap::Configuration
  end

  it "must cache configuration" do
    Sitemap.configuration.object_id.must_equal Sitemap.configuration.object_id
  end

  it "yields the current configuration" do
    Sitemap.configure do |config|
      config.must_equal Sitemap.configuration
    end
  end

end
