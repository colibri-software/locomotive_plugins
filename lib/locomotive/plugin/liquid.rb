
module Locomotive
  module Plugin
    module Liquid

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def add_liquid_tag_methods(base)
          base.extend(LiquidTagMethods)
        end
      end

      module LiquidTagMethods

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
        # :nodoc:
        def tag_subclass(tag_class)
          tag_class.class_eval <<-CODE
            class TagSubclass < #{tag_class.to_s}
              include ::Locomotive::Plugin::TagSubclassMethods
            end
          CODE
          tag_class::TagSubclass
        end

      end

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
