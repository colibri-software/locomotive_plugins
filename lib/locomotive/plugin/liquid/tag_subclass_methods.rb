
module Locomotive
  module Plugin
    module Liquid
      module TagSubclassMethods
        def render(context)
          if context.registers[:enabled_plugin_tags].include?(self.class)
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
