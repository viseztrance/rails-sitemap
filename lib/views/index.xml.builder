xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  entries.each do |entry|
    xml.url do
      xml.url polymorphic_url(entry[:object], entry[:params])
      xml.lastmod entry[:object].updated_at.strftime("%Y-%m-%d") if entry[:object].respond_to?(:updated_at)
      entry[:search].each do |type, value|
        xml.tag! SEARCH_ATTRIBUTES[type], value.to_s
      end
    end
  end

end

