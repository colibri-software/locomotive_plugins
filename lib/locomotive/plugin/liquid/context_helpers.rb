
module Locomotive
  module Plugin
    module Liquid
      # @api internal
      #
      # Adds the plugin object to the liquid context.
      module ContextHelpers

        # Adds the plugin object to the liquid context object to be used by
        # tags, filters, and drops. This method looks in the +:site+ register
        # for an object which responds to +#plugin_object_for_id+ in order to
        # populate the +:plugin_object+ register.  If such an object does not
        # exist, the method simply yields without altering the context object.
        # Otherwise, after yielding, the context object is reset to its
        # previous state.
        #
        # @param plugin_id [String] the plugin id to use
        # @param context [Liquid::Context] the liquid context object
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

        # Fetch the site from the context assuming it exists and responds to
        # the +#plugin_object_for_id+ method.
        #
        # @param context [Liquid::Context] the liquid context object
        # @return the site object or +nil+
        def self.fetch_site(context)
          site = context.registers[:site]
          site if site.respond_to?(:plugin_object_for_id)
        end
      end
    end
  end
end
