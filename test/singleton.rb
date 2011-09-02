# Reset singleton
# http://blog.ardes.com/2006/12/11/testing-singletons-with-ruby
class << Singleton

  def included_with_reset(klass)

    included_without_reset(klass)

    class << klass

      def reset_instance
        Singleton.send :__init__, self
        self
      end

    end

  end

  alias_method :included_without_reset, :included

  alias_method :included, :included_with_reset

end
