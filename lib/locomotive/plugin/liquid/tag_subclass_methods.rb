
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

          p = Proc.new do
            if enabled
              super
            elsif self.respond_to?(:render_disabled)
              self.render_disabled(context)
            else
              ''
            end
          end

          ret = nil
          rendering_tag(self.class.prefix, enabled, context) do
            ret = p.call
          end
          ret || p.call
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
