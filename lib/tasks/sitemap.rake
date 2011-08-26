namespace :sitemap do

  desc "Generates a new sitemap."
  task :generate => :environment do
    require File.join(Rails.root, "config", "sitemap")
    Sitemap::Generator.instance.save File.join(Rails.root, "public", "sitemap.xml")
  end

end
