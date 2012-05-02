require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Configuration" do

  before do
    Sitemap.configuration.reset
  end

  it "should inherit defaults" do
    Sitemap.configuration.query_batch_size.must_equal 500
  end

  it "should assign attributes" do
    Sitemap.configure do |config|
      config.query_batch_size = 200
    end
    Sitemap.configuration.query_batch_size.must_equal 200
  end

  it "should assign nested attribute values" do
    Sitemap.configure do |config|
      config.params_format = "html"
      config.search_change_frequency = "monthly"
    end
    Sitemap.configuration.params_format.must_equal "html"
    Sitemap.configuration.search_change_frequency.must_equal "monthly"
  end

  it "can be reset" do
    Sitemap.configure do |config|
      config.params_format = "html"
    end
    Sitemap.configuration.reset
    Sitemap.configuration.params_format.must_be_nil
  end

end
