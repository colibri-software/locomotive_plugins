
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
          ret = nil
          helper = ::Locomotive::Plugin::Liquid::ContextHelpers
          helper.add_plugin_object_to_context(self._plugin_id, @context) do
            ret = super
          end
          ret
        end
        alias :[] :invoke_drop

        protected

        attr_reader :_plugin_id

      end
    end
  end
end
