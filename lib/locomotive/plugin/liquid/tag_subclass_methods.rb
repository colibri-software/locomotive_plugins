
module Locomotive
  module Plugin
    module Liquid
      # @api internal
      #
      # The methods shared by all tag subclasses.
      module TagSubclassMethods

        # Check to see if this tag is enabled in the liquid context and render
        # accordingly.
        #
        # @param context [Liquid::Context] the liquid context object
        # @return the rendered content of the superclass using +render+ or
        #         +render_disabled+ as appropriate
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

        # The prefix for this tag.
        def prefix
          self.class.prefix
        end

      end
    end
  end
end
