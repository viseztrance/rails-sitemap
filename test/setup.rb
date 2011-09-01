module TestApp

  class Application < Rails::Application
    config.active_support.deprecation = :log
  end

end

TestApp::Application.initialize!

TestApp::Application.routes.draw do

  root :to => "main#index"

  match "/questions" => "static#faq", :as => "faq"

  resources :activities

end

module SitemapTestSetup

  def create_db
    # Database
    ActiveRecord::Schema.define(:version => 1) do
      create_table :activities do |t|
        t.string :name
        t.text :contents
        t.string :location
        t.timestamps
      end
    end
    1.upto(8) do |i|
      options = {
        :name => "Coding #{i}",
        :contents => "Lorem ipsum dolor sit",
        :location => "someplace-#{i}"
      }
      Activity.create!(options)
    end
  end

  def drop_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

end
