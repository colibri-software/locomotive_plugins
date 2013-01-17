
module Locomotive
  module Plugin
    # This module adds liquid handling methods to the plugin class.
    module Liquid

      # @private
      #
      # Add class methods.
      #
      # @param base the class which includes this module
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @api internal
      module ClassMethods
        # Adds methods from LiquidClassMethods module.
        #
        # @param base the plugin class to extend LiquidClassMethods
        def add_liquid_tag_methods(base)
          base.extend(LiquidClassMethods)
        end
      end

      # This module adds class methods to the plugin class in order to generate
      # the prefixed liquid filter module and generate and register the
      # prefixed liquid tag classes.
      module LiquidClassMethods

        # Gets the module to include as a filter in liquid. It prefixes the
        # filter methods with the given string followed by an underscore.
        #
        # @param prefix [String] the prefix to use
        # @return the module to use as a filter module
        def prefixed_liquid_filter_module(prefix)
          # Create the module to be returned
          @prefixed_liquid_filter_module = Module.new do
            include ::Locomotive::Plugin::Liquid::PrefixedFilterModule
          end

          # Add the prefixed methods to the module
          raw_filter_modules = [self.liquid_filters].flatten.compact
          raw_filter_modules.each do |mod|
            mod.public_instance_methods.each do |meth|
              @prefixed_liquid_filter_module.module_eval do
                define_method(:"#{prefix}_#{meth}") do |*args|
                  self._passthrough_filter_call(prefix, meth, *args)
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

        # Returns a hash of tag names and tag classes to be registered in the
        # liquid environment. The tag names are prefixed by the given prefix
        # followed by an underscore, and the tag classes are modified so that
        # they check the liquid context to determine whether they are enabled
        # and should render normally. This check is done by determining whether
        # the tag class is in the +:enabled_plugin_tags+ register in the liquid
        # context object (see +setup_liquid_context+).
        #
        # @param prefix [String] the prefix to use
        # @return a hash of tag names to tag classes
        def prefixed_liquid_tags(prefix)
          self.liquid_tags.inject({}) do |hash, (tag_name, tag_class)|
            hash["#{prefix}_#{tag_name}"] = tag_subclass(prefix, tag_class)
            hash
          end
        end

        # Registers the tags given by +prefixed_liquid_tags+ in the liquid
        # template system.
        #
        # @param prefix [String] the prefix to give to +prefixed_liquid_tags+
        def register_tags(prefix)
          prefixed_liquid_tags(prefix).each do |tag_name, tag_class|
            ::Liquid::Template.register_tag(tag_name, tag_class)
          end
        end

        protected

        # Creates a nested subclass to handle rendering the given tag.
        #
        # @param prefix [String] the prefix for the tag class
        # @param tag_class the liquid tag class to subclass
        # @return the appropriate tag subclass
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

      # Setup the liquid context object for rendering plugin liquid code. It
      # will add to the context:
      #
      # * the prefixed tags. These will go into the +:enabled_plugin_tags+
      #   register.
      # * the drop to the hash in the +"plugins"+ liquid variable
      # * the prefixed filters.
      #
      # @param plugin_id [String] the plugin id to use
      # @param context [Liquid::Context] the liquid context object
      def setup_liquid_context(plugin_id, context)
        # Add tags
        (context.registers[:enabled_plugin_tags] ||= Set.new).tap do |set|
          set.merge(self.class.prefixed_liquid_tags(plugin_id).values)
        end

        # Add drop with extension
        drop = self.to_liquid
        drop.extend(Locomotive::Plugin::Liquid::DropExtension)
        drop.set_plugin_id(plugin_id)
        (context['plugins'] ||= {})[plugin_id] = drop

        # Add filters
        context.add_filters(self.class.prefixed_liquid_filter_module(plugin_id))
      end

    end
  end
end
