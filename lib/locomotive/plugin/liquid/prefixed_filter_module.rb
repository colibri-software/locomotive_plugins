
module Locomotive
  module Plugin
    module Liquid
      # This module provides functionality for the module which aggregates all
      # the prefixed filter methods. This module expects the
      # <tt>_filter_modules_to_extend</tt> method to be defined on the object
      # which mixes it in. see
      # <tt>Locomotive::Plugin::Liquid#prefixed_liquid_filter_module</tt>
      # :nodoc:
      module PrefixedFilterModule

        protected

        # Object to pass all filter methods to
        def _passthrough_object
          if @_passthrough_object
            return @_passthrough_object
          end

          # Build object and extend actual filter modules
          @_passthrough_object = Object.new
          self._filter_modules_to_extend.each do |mod|
            @_passthrough_object.extend(mod)
          end
          @_passthrough_object
        end

        def _passthrough_filter_call(meth, input)
          self._passthrough_object.public_send(meth, input)
        end

      end
    end
  end
end
