require "rails"

module Sitemap

  class Railtie < Rails::Railtie

    rake_tasks do
      load "tasks/sitemap.rake"
    end

  end

end
