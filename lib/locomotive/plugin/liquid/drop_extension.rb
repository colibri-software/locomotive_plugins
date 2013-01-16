
module Locomotive
  module Plugin
    module Liquid
      # @api internal
      #
      # Extension to liquid drops added by plugins.
      module DropExtension

        # Allow setting the plugin_id, but only once.
        def set_plugin_id(plugin_id)
          @_plugin_id ||= plugin_id
        end

        # Add the plugin object to the context when invoked (see
        # Liquid::Drop#invoke_drop)
        def invoke_drop(method)
          value = nil

          ContextHelpers.add_plugin_object_to_context(_plugin_id, @context) do
            value = super
          end

          value
        end
        alias :[] :invoke_drop

        private

        # Plugin ID (see set_plugin_id).
        attr_reader :_plugin_id

      end
    end
  end
end
