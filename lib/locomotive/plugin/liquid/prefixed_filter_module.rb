
module Locomotive
  module Plugin
    module Liquid
      # @private
      # This module provides functionality for the module which aggregates all
      # the prefixed filter methods. See
      # <tt>Locomotive::Plugin::Liquid#prefixed_liquid_filter_module</tt>
      module PrefixedFilterModule

        protected

        def _build_passthrough_object(modules_to_extend)
          Object.new.tap do |obj|
            modules_to_extend.each do |mod|
              obj.extend(mod)
            end
          end
        end

      end
    end
  end
end
