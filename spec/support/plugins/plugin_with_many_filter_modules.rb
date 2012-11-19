
module Locomotive
  class PluginWithManyFilterModules
    include Locomotive::Plugin

    module Filters
      def add_newline(input)
        "#{input}\n"
      end
    end

    module MoreFilters
      def remove_http(input)
        input.sub(%r{^http://}, '')
      end
    end

    def self.liquid_filters
      [ Filters, MoreFilters ]
    end

  end
end
