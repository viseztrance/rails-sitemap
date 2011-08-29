xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  entries.each do |entry|
    xml.url do
      xml.url get_url(entry)
      xml.lastmod entry[:object].updated_at.strftime("%Y-%m-%d") if entry[:object].respond_to?(:updated_at)
      xml.changefreq entry[:options][:change_frequency] if entry[:options][:change_frequency]
      xml.priority entry[:options][:priority] if entry[:options][:priority]
    end
  end

end

