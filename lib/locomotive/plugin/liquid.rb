
module Locomotive
  module Plugin
    module Liquid

      # @private
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @private
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
            hash["#{prefix}_#{tag_name}"] = tag_subclass(prefix, tag_class)
            hash
          end
        end

        protected

        # Creates a nested subclass to handle rendering this tag
        def tag_subclass(prefix, tag_class)
          tag_class.class_eval <<-CODE
            class TagSubclass < #{tag_class.to_s}
              include ::Locomotive::Plugin::TagSubclassMethods

              def self.prefix
                '#{prefix}'
              end
            end
          CODE
          tag_class::TagSubclass
        end

      end

      # Gets the module to include as a filter in liquid. It prefixes the
      # filter methods with the given string
      def prefixed_liquid_filter_module(prefix)
        # Create the module to be returned
        @prefixed_liquid_filter_module = Module.new do
          include ::Locomotive::Plugin::Liquid::PrefixedFilterModule
        end

        # Add the prefixed methods to the module
        raw_filter_modules = [self.class.liquid_filters].flatten.compact
        raw_filter_modules.each do |mod|
          mod.public_instance_methods.each do |meth|
            @prefixed_liquid_filter_module.module_eval do
              define_method(:"#{prefix}_#{meth}") do |input|
                self._passthrough_filter_call(prefix, meth, input)
              end
            end
          end
        end

        # Add a method which returns the modules to include for this prefix
        @prefixed_liquid_filter_module.module_eval do
          protected

          define_method(:"_modules_for_#{prefix}") do
            raw_filter_modules
          end
        end

        @prefixed_liquid_filter_module
      end

    end
  end
end
