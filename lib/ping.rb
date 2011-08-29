require "net/http"
require "cgi"

module Sitemap

  class Ping

    SEARCH_ENGINES = {
      "Google"  => "http://www.google.com/webmasters/tools/ping?sitemap=%s",
      "Yahoo!"  => "http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=SitemapWriter&url=%s",
      "Ask.com" => "http://submissions.ask.com/ping?sitemap=%s",
      "Bing"    => "http://www.bing.com/webmaster/ping.aspx?siteMap=%s"
    }

    def self.send_request(file_path)
      SEARCH_ENGINES.each do |name, url|
        puts Net::HTTP.get(url % file_path).inspect
      end
    end

  end

end
