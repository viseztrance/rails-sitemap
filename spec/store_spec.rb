require "minitest/autorun"
require File.expand_path("../minitest_helper", __FILE__)

describe "Store" do

  it "should append entries" do
    store = Sitemap::Store.new(:max_entries => 1000)
    3.times { store << "contents" }
    store.entries.length.must_equal 3
  end

  it "should reset entries when limit is reached" do
    store = Sitemap::Store.new(:max_entries => 2)
    2.times { store << "contents" }
    store.entries.length.must_equal 2
    store << "contents"
    store.entries.length.must_equal 1
  end

  describe "when a reset has occurred" do

    it "should run a callback" do
      store = Sitemap::Store.new(:max_entries => 2)
      store.before_reset do |entries|
        store.instance_variable_set("@callback_data", entries.join(", "))
      end
      3.times { |i| store << "item #{i + 1}" }
      store.instance_variable_get("@callback_data").must_equal "item 1, item 2"
    end

    it "should increement reset count" do
      store = Sitemap::Store.new(:max_entries => 2)
      5.times { store << "contents" }
      store.reset_count.must_equal 2
    end

  end

end
