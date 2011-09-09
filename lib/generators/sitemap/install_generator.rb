module Sitemap

  module Generators

    class InstallGenerator < Rails::Generators::Base

      source_root File.expand_path('../templates', __FILE__)

      def generate_config
        copy_file "sitemap.rb", "config/sitemap.rb"
      end

    end

  end

end
