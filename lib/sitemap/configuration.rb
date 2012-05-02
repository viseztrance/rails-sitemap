module Sitemap

  class Configuration

    module Defaults

      PARAMS = {}.freeze

      SEARCH = {
        :updated_at => proc { |obj|
          obj.updated_at.strftime("%Y-%m-%d") if obj.respond_to?(:updated_at)
        }
      }.freeze

      QUERY_BATCH_SIZE = 500

      MAX_URLS = 10000

    end

    attr_accessor :data

    def initialize
      reset
    end

    def reset
      self.data = {
        :params           => Defaults::PARAMS.dup,
        :search           => Defaults::SEARCH.dup,
        :query_batch_size => Defaults::QUERY_BATCH_SIZE,
        :max_urls         => Defaults::MAX_URLS
      }
    end

    def params
      data[:params]
    end

    def search
      data[:search]
    end

    def method_missing(method, *args, &block)
      if /^(?<prefix>search|params)?_?(?<name>[a-z\_]+)(?<setter>=)?/ =~ method
        if prefix
          if setter
            self.data[prefix.to_sym][name.to_sym] = args.first
          else
            data[prefix.to_sym][name.to_sym]
          end
        else
          if setter
            self.data[name.to_sym] = args.first
          else
            data[name.to_sym]
          end
        end
      else
        super(method, *args, &block)
      end
    end

  end

end
