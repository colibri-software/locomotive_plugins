
module Locomotive
  module Plugin
    module Liquid

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods # :nodoc:
        def add_liquid_tag_methods(base)
          base.extend(LiquidTagMethods)
        end
      end

      module LiquidTagMethods

        # :category: Utility
        #
        # Returns a hash of tag names and tag classes to be registered in the
        # liquid environment. The tag names are prefixed by the given prefix,
        # and the tag classes are modified so that they check the liquid
        # context to determine whether they are enabled and should render
        # normally
        def prefixed_liquid_tags(prefix)
          self.liquid_tags.inject({}) do |hash, (tag_name, tag_class)|
            hash["#{prefix}_#{tag_name}"] = tag_subclass(tag_class)
            hash
          end
        end

        # Creates a nested subclass to handle rendering this tag
        def tag_subclass(tag_class) # :nodoc:
          tag_class.class_eval <<-CODE
            class TagSubclass < #{tag_class.to_s}
              include ::Locomotive::Plugin::TagSubclassMethods
            end
          CODE
          tag_class::TagSubclass
        end

      end

      # :category: Utility
      #
      # Gets the module to include as a filter in liquid. It prefixes the
      # filter methods with the given string
      def prefixed_liquid_filter_module(prefix)
        # Build up a string to eval into the module so we only need to reopen
        # it once
        strings_to_eval = []

        raw_filter_modules = [self.class.liquid_filters].flatten.compact
        raw_filter_modules.each do |mod|
          mod.public_instance_methods.each do |meth|
            strings_to_eval << <<-CODE
              def #{prefix}_#{meth}(input)
                self._passthrough_filter_call_for_#{prefix}('#{meth}', input)
              end
            CODE
          end
        end

        strings_to_eval << <<-CODE
          protected

          def _passthrough_object_for_#{prefix}
            @_passthrough_object_for_#{prefix} ||= \
              self._build_passthrough_object([#{raw_filter_modules.join(',')}])
          end

          def _passthrough_filter_call_for_#{prefix}(meth, input)
            self._passthrough_object_for_#{prefix}.public_send(meth, input)
          end
        CODE

        # Eval the dynamic methods in
        @prefixed_liquid_filter_module = Module.new do
          include ::Locomotive::Plugin::Liquid::PrefixedFilterModule
        end
        @prefixed_liquid_filter_module.class_eval strings_to_eval.join("\n")
        @prefixed_liquid_filter_module
      end

    end
  end
end
