
module Locomotive
  module Plugin
    module Liquid
      # @private
      module TagSubclassMethods

        # Check to see if this tag is enabled in the liquid context and render
        # accordingly
        def render(context)
          enabled_tags = context.registers[:enabled_plugin_tags]
          enabled = enabled_tags && enabled_tags.include?(self.class)

          output = nil

          ContextHelpers.add_plugin_object_to_context(self.prefix, context) do
            output = if enabled
              super
            elsif self.respond_to?(:render_disabled)
              self.render_disabled(context)
            else
              ''
            end
          end

          output
        end

        def prefix
          self.class.prefix
        end

        protected

        # This method is overridden by LocomotiveCMS to provide custom
        # functionality when the tag is rendering
        def rendering_tag(prefix, enabled, context)
        end

      end
    end
  end
end
