namespace :sitemap do

  def setup
    require File.join(Rails.root, "config", "sitemap")
  end

  desc "Generates a new sitemap."
  task :generate => :environment do
    setup
    path = File.join(Rails.public_path, "sitemap.xml")
    Sitemap::Generator.instance.save path
  end

  desc "Ping engines."
  task :ping => :environment do
    Sitemap::Ping.send_request ENV["LOCATION"]
  end

end
