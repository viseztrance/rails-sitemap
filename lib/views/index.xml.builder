xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  entries.each do |entry|
    xml.url do
      xml.url get_url(entry)
      xml.lastmod entry[:object].updated_at.strftime("%Y-%m-%d") unless entry[:object].is_a?(Symbol)
      entry[:options].each do |type, value|
        xml.tag! type, value.to_s
      end
    end
  end

end

