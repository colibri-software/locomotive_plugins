
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

      def link_to(input, href)
        %{<a href="#{href}">#{input}</a>}
      end
    end

    def self.liquid_filters
      Filters
    end

  end
end
