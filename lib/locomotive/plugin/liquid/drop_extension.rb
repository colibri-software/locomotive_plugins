
module Locomotive
  module Plugin
    module Liquid
      module DropExtension

        # Allow setting the plugin_id, but only once
        def set_plugin_id(plugin_id)
          @_plugin_id ||= plugin_id
        end

        # Set the context when the drop is invoked
        def invoke_drop(method)
          value = nil

          ContextHelpers.add_plugin_object_to_context(self._plugin_id, @context) do
            value = super
          end

          value
        end
        alias :[] :invoke_drop

        protected

        attr_reader :_plugin_id

      end
    end
  end
end
