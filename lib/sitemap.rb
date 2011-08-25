#
# = sitemap.rb - Sitemap
#
# Author:: Daniel Mircea daniel@viseztrance.com
# Copyright:: Copyright (c) 2011 Daniel Mircea, The Geeks
# License:: MIT and/or Creative Commons Attribution-ShareAlike

gem "builder", "~> 2.1.2"

require "singleton"
require "builder"

class Sitemap

  include Singleton
  include Rails.application.routes.url_helpers

  VERSION = Gem::Specification.load(File.expand_path("../sitemap.gemspec", File.dirname(__FILE__))).version.to_s

  attr_accessor :entries, :host

  def initialize
    self.entries = []
  end

  def render(options = {}, &block)
    options.each do |k, v|
      self.send("#{k}=", v)
    end
    instance_exec(self, &block)
  end

  def path(object, options = {})
    self.entries << {
      :object => object,
      :options => options.reject { |k, v| k == :host },
      :host => options[:host]
    }
  end

  def collection(type, options = {})
    objects = options[:objects] ? options[:objects].call : type.to_s.classify.constantize.all
    objects.each do |object|
      path(object, options.reject { |k, v| k == :objects })
    end
  end

  def build
    xml = Builder::XmlMarkup.new(:indent => 2)
    file = File.read(File.expand_path("../views/index.xml.builder", __FILE__))
    instance_eval file
  end

  def save(location)
    file = File.new(location, "w")
    file.write(build)
    file.close
  end

  def get_url(entry)
    options = {
      :host => entry[:host] ? entry[:host].call(entry[:object]) : host
    }
    polymorphic_url(entry[:object], options)
  end

end
