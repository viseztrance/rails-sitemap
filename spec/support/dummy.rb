module TestApp

  class Application < Rails::Application
    config.active_support.deprecation = :log
  end

end

TestApp::Application.initialize!

TestApp::Application.routes.draw do

  root :to => "main#index"

  get "/questions" => "static#faq", :as => "faq"

  resources :activities

end

class Activity < ActiveRecord::Base; end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.verbose = false
