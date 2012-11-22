
module Locomotive
  class PluginWithTags

    include Locomotive::Plugin

    class Paragraph < ::Liquid::Block
      def render(context)
        "<p>#{render_all(@nodelist, context)}</p>"
      end

      def render_disabled(context)
        render_all(@nodelist, context)
      end
    end

    class Newline < ::Liquid::Tag
      def render(context)
        "<br />"
      end
    end

    def self.liquid_tags
      {
        :paragraph => Paragraph,
        :newline => Newline
      }
    end

  end
end
