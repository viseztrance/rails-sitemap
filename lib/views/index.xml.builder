xml.instruct!
xml.sitemapindex :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  fragments.each_with_index do |fragment, i|
    xml.sitemap do
      xml.loc file_url("sitemaps/sitemap-fragment-#{i + 1}.xml")
      xml.lastmod Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    end
  end

end
