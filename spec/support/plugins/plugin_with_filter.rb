
module Locomotive
  class PluginWithFilter
    include Locomotive::Plugin

    module Filters
      def add_http(input)
        if input.start_with?('http://')
          input
        else
          "http://#{input}"
        end
      end
    end

    def liquid_filters
      Filters
    end

  end
end
