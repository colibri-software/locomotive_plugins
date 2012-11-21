
module Locomotive
  module Plugin
    module Liquid
      module TagSubclassMethods # :nodoc:
        # Check to see if this tag is enabled in the liquid context and render
        # accordingly
        def render(context)
          enabled = context.registers[:enabled_plugin_tags]
          if enabled && enabled.include?(self.class)
            super
          elsif self.respond_to?(:render_disabled)
            self.render_disabled(context)
          else
            ''
          end
        end
      end
    end
  end
end
