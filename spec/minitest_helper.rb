require "rails"
require "action_controller/railtie" # Rails 3.1
require "active_record"
require "nokogiri"

require File.expand_path("../support/dummy", __FILE__)
require File.expand_path("../support/singleton", __FILE__)
require File.expand_path("../lib/sitemap", File.dirname(__FILE__))

def create_db
  # Database
  ActiveRecord::Schema.define(:version => 1) do
    create_table :activities do |t|
      t.string :name
      t.text :contents
      t.string :location
      t.boolean :published, :default => true
      t.timestamps
    end
  end
  1.upto(8) do |i|
    options = {
      :name => "Coding #{i}",
      :contents => "Lorem ipsum dolor sit",
      :location => "someplace-#{i}",
      :published => (i < 6)
    }
    Activity.create!(options)
  end
end

def drop_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
