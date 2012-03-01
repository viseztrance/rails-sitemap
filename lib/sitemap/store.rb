module Sitemap

  class Store

    attr_accessor :entries, :max_entries, :reset_count, :before_reset_callback

    def initialize(options = {})
      self.entries     = []
      self.reset_count = 0
      self.max_entries = options[:max_entries]
    end

    def << entry
      reset! if entries.length >= max_entries
      self.entries << entry
    end

    def reset!
      before_reset_callback.call(entries) if before_reset_callback
      self.entries = []
      self.reset_count += 1
    end

    def before_reset(&block)
      self.before_reset_callback = block
    end

  end

end
