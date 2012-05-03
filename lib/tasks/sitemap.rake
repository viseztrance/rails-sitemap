namespace :sitemap do

  def setup
    require File.join(Rails.root, "config", "sitemap")
  end

  desc "Generates a new sitemap."
  task :generate => :environment do
    setup
    root = Sitemap.configuration.save_path || ENV["LOCATION"] || Rails.public_path
    path = File.join(root, "sitemap.xml")
    Sitemap::Generator.instance.build!
    Sitemap::Generator.instance.save path
  end

  desc "Ping engines."
  task :ping => :environment do
    Sitemap::Ping.send_request ENV["LOCATION"]
  end

end
