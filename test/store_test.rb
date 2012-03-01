require "test/unit"
require "rubygems"

class StoreTest < Test::Unit::TestCase

  def test_append_entries
    store = Sitemap::Store.new(:max_entries => 1000)
    3.times { store << "contents" }
    assert_equal store.entries.length, 3
  end

  def test_reset_entries_limit
    store = Sitemap::Store.new(:max_entries => 2)
    2.times { store << "contents" }
    assert_equal store.entries.length, 2
    store << "contents"
    assert_equal store.entries.length, 1
  end

  def test_reset_callback
    store = Sitemap::Store.new(:max_entries => 2)
    store.before_reset do |entries|
      store.instance_variable_set("@callback_data", entries.join(", "))
    end
    3.times { |i| store << "item #{i + 1}" }
    assert_equal store.instance_variable_get("@callback_data"), "item 1, item 2"
  end

  def test_increments_reset_count
    store = Sitemap::Store.new(:max_entries => 2)
    5.times { store << "contents" }
    assert_equal store.reset_count, 2
  end

end
