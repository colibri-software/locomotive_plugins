
module Locomotive
  module Plugin
    # This module provides initialization methods to the plugin class which Locomotive CMS will call after the plugin has been loaded into the app.
    module LoadInitialization

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
        # Adds methods from LoadInitializationClassMethods module.
        #
        # @param base the plugin class to extend LoadInitializationClassMethods
        def add_load_initialization_class_methods(base)
          base.extend(LoadInitializationClassMethods)
        end
      end

      # This module adds class-level initialization methods to the plugin class.
      module LoadInitializationClassMethods
        # Performs class-level initialization and ensures that it is only done
        # once. If a block is given, that block is called before the custom
        # `plugin_loaded` method is called. LocomotiveCMS calls this method on
        # all plugins after they are loaded.
        def do_load_initialization
          raise InitializationError,
            'cannot initialize plugin more than once!' if @done_load_inialization

          @done_load_inialization = true

          yield if block_given?

          self.plugin_loaded
        end
      end

    end
  end
end
