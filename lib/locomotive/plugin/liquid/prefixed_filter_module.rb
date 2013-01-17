
module Locomotive
  module Plugin
    module Liquid
      # @api internal
      #
      # This module provides functionality for the module which aggregates all
      # the prefixed filter methods. See
      # <tt>Locomotive::Plugin::Liquid#prefixed_liquid_filter_module</tt>.
      module PrefixedFilterModule

        protected

        # Build the object to use for passing through the non-prefixed methods.
        #
        # @param modules_to_extend [Array] the module for the passthrough object
        # to extend
        def _build_passthrough_object(modules_to_extend)
          obj = ::Liquid::Strainer.new(@context)

          modules_to_extend.each do |mod|
            obj.extend(mod)
          end

          obj
        end

        # Get the passthrough object for the given prefix.
        #
        # @param prefix [String] the prefix to use
        # @return the passthrough object for +prefix+
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

        # Passthrough method call with the given prefix and input.
        #
        # @param prefix [String] the prefix to use
        # @param meth [Symbol] the method to call
        # @param input [String] the input to the method
        # @return the result of calling the method on the passthrough object
        def _passthrough_filter_call(prefix, meth, *args)
          # Setup context object and call the passthrough
          output = nil

          ContextHelpers.add_plugin_object_to_context(prefix, @context) do
            output = self._passthrough_object(prefix).__send__(meth, *args)
          end

          output
        end

      end
    end
  end
end
