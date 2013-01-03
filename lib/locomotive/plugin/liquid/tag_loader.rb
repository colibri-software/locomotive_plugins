module Locomotive
  module Plugin
    module Liquid
      class TagLoader

        # Load and register all prefixed plugin tags. Takes a hash of
        # plugin_ids to plugin_classes
        def self.load!(registered_plugins)
          registered_plugins.each do |plugin_id, plugin_class|
            plugin_class.prefixed_liquid_tags(plugin_id).each do |tag_name, tag_class|
              ::Liquid::Template.register_tag(tag_name, tag_class)
            end
          end
        end

      end
    end
  end
end
