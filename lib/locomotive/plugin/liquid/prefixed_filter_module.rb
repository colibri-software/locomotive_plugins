
module Locomotive
  module Plugin
    module Liquid
      # @private
      # This module provides functionality for the module which aggregates all
      # the prefixed filter methods. See
      # <tt>Locomotive::Plugin::Liquid#prefixed_liquid_filter_module</tt>
      module PrefixedFilterModule

        protected

        # This method is overridden by LocomotiveCMS to provide custom
        # functionality when a prefixed method is called
        def filter_method_called(prefix, meth)
        end

        def _build_passthrough_object(modules_to_extend)
          Object.new.tap do |obj|
            modules_to_extend.each do |mod|
              obj.extend(mod)
            end
          end
        end

        def _passthrough_object(prefix)
          @_passthrough_objects ||= {}
          obj = @_passthrough_objects[prefix]

          # Return it if we have it
          return obj if obj

          # Otherwise, build it
          modules_for_prefix_meth = :"_modules_for_#{prefix}"
          if self.respond_to?(modules_for_prefix_meth)
            modules = self.__send__(modules_for_prefix_meth)
          else
            modules = []
          end

          @_passthrough_objects[prefix] = self._build_passthrough_object(modules)
        end

        def _passthrough_filter_call(prefix, meth, input)
          p = Proc.new do
            self._passthrough_object(prefix).send(meth, input)
          end

          # Call hook and grab return value if it yields
          ret = nil
          self.filter_method_called(prefix, meth) do
            ret = p.call
          end

          ret || p.call
        end

      end
    end
  end
end
