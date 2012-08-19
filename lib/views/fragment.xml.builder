xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  store.entries.each do |entry|
    xml.url do
      xml.loc entry[:url] ? entry[:url] : polymorphic_url(entry[:object], entry[:params])
      entry[:search].each do |type, value|
        next if !value || value.blank?
        xml.tag! SEARCH_ATTRIBUTES[type], value.to_s
      end
    end
  end

end

