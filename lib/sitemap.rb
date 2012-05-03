#
# = sitemap.rb - Sitemap
#
# Author:: Daniel Mircea daniel@viseztrance.com
# Copyright:: 2011 (c) Daniel Mircea, {The Geeks}[http://thegeeks.ro]
# License:: MIT and/or Creative Commons Attribution-ShareAlike

require "singleton"
require "builder"
require "sitemap/version"
require "sitemap/configuration"
require "sitemap/railtie"
require "sitemap/ping"
require "sitemap/store"
require "sitemap/generator"

module Sitemap

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

end
