
module Locomotive
  module Plugin
    module Liquid

      # Gets the module to include as a filter in liquid. It prefixes the filter
      # methods with the given string
      def prefixed_liquid_filter_module(prefix)
        raw_filter_modules = [self.liquid_filters].flatten.compact

        @prefixed_liquid_filter_module = Module.new

        raw_filter_modules.each do |mod|
          @prefixed_liquid_filter_module.class_eval <<-CODE
            protected

            def _passthrough_object_for_#{prefix}
              if @_passthrough_object_for_#{prefix}
                return @_passthrough_object_for_#{prefix}
              end

              @_passthrough_object_for_#{prefix} = Object.new
              @_passthrough_object_for_#{prefix}.extend(#{mod.to_s})
              @_passthrough_object_for_#{prefix}
            end
          CODE

          mod.public_instance_methods.each do |meth|
            @prefixed_liquid_filter_module.class_eval <<-CODE
              def #{prefix}_#{meth}(input)
                self._passthrough_object_for_#{prefix}.#{meth}(input)
              end
            CODE
          end
        end

        @prefixed_liquid_filter_module
      end

    end
  end
end
