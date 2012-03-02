#
# = sitemap.rb - Sitemap
#
# Author:: Daniel Mircea daniel@viseztrance.com
# Copyright:: 2011 (c) Daniel Mircea, {The Geeks}[http://thegeeks.ro]
# License:: MIT and/or Creative Commons Attribution-ShareAlike

require "singleton"
require "builder"
require "sitemap/railtie"
require "sitemap/ping"
require "sitemap/store"
require "sitemap/generator"

module Sitemap

  VERSION = Gem::Specification.load(File.expand_path("../sitemap.gemspec", File.dirname(__FILE__))).version.to_s

  mattr_accessor :defaults

  self.defaults = {
    :params => {},
    :search => {
      :updated_at => proc { |obj|
        obj.updated_at.strftime("%Y-%m-%d") if obj.respond_to?(:updated_at)
      }
    },
    :query_batch_size => 500,
    :max_urls => 10000
  }

end
