
module Locomotive
  module Plugin
    module Liquid
      # @private
      # Adds the plugin object to the liquid context object to be used by tags,
      # filters, and drops. The add_plugin_object_to_context method looks in
      # context.registers[:site] for an object which responds to
      # #plugin_object_for_id in order to populate
      # context.registers[:plugin_object]. If such an object does not exist, the
      # method simply yields without altering the context object. Otherwise, after
      # yielding, the context object is reset to its previous state
      module ContextHelpers
        def self.add_plugin_object_to_context(plugin_id, context)
          site = self.fetch_site(context)
          if site
            old = context.registers[:plugin_object]
            obj = site.plugin_object_for_id(plugin_id)
            context.registers[:plugin_object] = obj
            yield
            context.registers[:plugin_object] = old
          else
            yield
          end
        end

        protected

        def self.fetch_site(context)
          site = context.registers[:site]
          site if site.respond_to?(:plugin_object_for_id)
        end
      end
    end
  end
end
