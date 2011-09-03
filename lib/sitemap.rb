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

module Sitemap

  VERSION = Gem::Specification.load(File.expand_path("../sitemap.gemspec", File.dirname(__FILE__))).version.to_s

  mattr_accessor :defaults

  self.defaults = {
    :params => {},
    :search => {
      :updated_at => proc { |obj| obj.updated_at.strftime("%Y-%m-%d") if obj.respond_to?(:updated_at) }
    }
  }

  class Generator

    include Singleton

    SEARCH_ATTRIBUTES = {
      :updated_at       => "lastmod",
      :change_frequency => "changefreq",
      :priority         => "priority"
    }

    attr_accessor :entries, :host, :routes

    # Instantiates a new object.
    # Should never be called directly.
    def initialize
      self.class.send(:include, Rails.application.routes.url_helpers)
      self.entries = []
    end

    # Sets the urls to be indexed.
    #
    # The +host+, or any other global option can be set here:
    #
    #   Sitemap::Generator.instance.load :host => "mywebsite.com" do
    #     ...
    #   end
    #
    # Simple paths can be added as follows:
    #
    #   Sitemap::Generator.instance.load :host => "mywebsite.com" do
    #     path :faq
    #   end
    #
    # Object collections are supported too:
    #
    #   Sitemap::Generator.instance.load :host => "mywebsite.com" do
    #     resources :activities
    #   end
    #
    # Search options such as frequency and priority can be declared as an options hash:
    #
    #   Sitemap::Generator.instance.load :host => "mywebsite.com" do
    #     path :root, :priority => 1
    #     path :faq, :priority => 0.8, :change_frequency => "daily"
    #     resources :activities, :change_frequency => "weekly"
    #   end
    #
    def load(options = {}, &block)
      options.each do |k, v|
        self.send("#{k}=", v)
      end
      self.routes = block
    end

    # Adds the specified url or object (such as an ActiveRecord model instance).
    # In either case the data is being looked up in the current application routes.
    #
    # Params can be specified as follows:
    #
    #   # config/routes.rb
    #   match "/frequent-questions" => "static#faq", :as => "faq"
    #
    #   # config/sitemap.rb
    #   path :faq, :params => { :filter => "recent" }
    #
    # The resolved url would be <tt>http://mywebsite.com/frequent-questions?filter=recent</tt>.
    #
    def path(object, options = {})
      params = Sitemap.defaults[:params].clone.merge!(options[:params] || {})
      params[:host] ||= host # Use global host if none was specified.
      params.merge!(params) { |type, value| get_data(object, value) }

      search = Sitemap.defaults[:search].clone.merge!(options.select { |k, v| SEARCH_ATTRIBUTES.keys.include?(k) })
      search.merge!(search) { |type, value| get_data(object, value) }

      self.entries << {
        :object => object,
        :search => search,
        :params => params
      }
    end

    # Adds the associated object types.
    #
    # The following will map all Activity entries, as well as the index (<tt>/activities</tt>) page:
    #
    #   resources :activities
    #
    # You can also specify which entries are being mapped:
    #
    #   resources :articles, :objects => proc { Article.published }
    #
    # To skip the index action and map only the records:
    #
    #   resources :articles, :skip_index => true
    #
    # As with the path, you can specify params through the +params+ options hash.
    # The params can also be build conditionally by using a +proc+:
    #
    #   resources :activities, :params => { :host => proc { |activity| [activity.location, host].join(".") } }, :skip_index => true
    #
    # In this case the host will change based the each of the objects associated +location+ attribute.
    # Because the index page doesn't have this attribute it's best to skip it.
    #
    def resources(type, options = {})
      path(type) unless options[:skip_index]
      objects = options[:objects] ? options[:objects].call : type.to_s.classify.constantize.all
      options.reject! { |k, v| k == :objects }

      objects.each do |object|
        path(object, options)
      end
    end

    # Parses the loaded data and returns the xml entries.
    def build
      instance_exec(self, &routes)
      xml = Builder::XmlMarkup.new(:indent => 2)
      file = File.read(File.expand_path("../views/index.xml.builder", __FILE__))
      instance_eval file
    end

    # Builds xml entries and saves the data to the specified location.
    def save(location)
      file = File.new(location, "w")
      file.write(build)
      file.close
    end

    # URL to the <tt>sitemap.xml</tt> file.
    def file_url
      URI::HTTP.build(:host => host, :path => "/sitemap.xml").to_s
    end

    private

    def get_data(object, data)
      data.is_a?(Proc) ? data.call(object) : data
    end

  end

end
