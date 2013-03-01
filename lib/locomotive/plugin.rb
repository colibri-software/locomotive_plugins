
Dir.glob(File.join(File.dirname(__FILE__), 'plugin', '**', '*.rb')) do |f|
  require f
end

module Locomotive

  # Include this module in a class which should be registered as a Locomotive
  # plugin. See the documentation for the various methods which can be called
  # or overridden to describe the plugin.
  module Plugin

    include ClassTracker
    include ConfigUI
    include LoadInitialization
    include Liquid
    include RackAppHelpers

    # @private
    #
    # Set up the plugin class with some class methods, callbacks, and plugin
    # class tracking.
    #
    # @param base the plugin class
    def self.included(base)
      self.add_load_initialization_class_methods(base)
      self.add_liquid_class_methods(base)

      base.class_eval do
        extend ActiveModel::Callbacks
        define_model_callbacks :page_render
        define_model_callbacks :rack_app_request
      end

      base.extend ClassMethods

      self.track_plugin_class(base)
    end

    module ClassMethods
      # Override this method to specify the default plugin_id to use when
      # Locomotive registers the plugin. This plugin_id may be overridden by
      # Locomotive CMS.
      #
      # @return by default, the underscored plugin class name (without the
      #         namespace)
      def default_plugin_id
        to_s.split('::').last.underscore
      end

      # Override this method to provide a module or array of modules to include
      # as liquid filters in the site. All public methods in the module will be
      # included as filters after being prefixed with the plugin id
      # (#\\{plugin_id}_#\\{method_name}).
      #
      # @example
      #   class MyPlugin
      #     def self.liquid_filters
      #       [ MyFilters, MoreFilters ]
      #     end
      #   end
      def liquid_filters
        nil
      end

      # Override this method to specify the liquid tags supplied by this
      # plugin. The return value must be a hash whose keys are the tag names
      # and values are the tag classes. The tag names will be included in
      # Locomotive's liquid renderer after being prefixed with the plugin id
      # (#\\{plugin_id}_#\\{tag_name}).
      #
      # @example
      #   class MyPlugin
      #     def self.liquid_tags
      #       { :my_tag => MyTag, :other_tag => OtherTag }
      #     end
      #   end
      def liquid_tags
        {}
      end

      # Override this method to provide functionality which will be executed
      # when the CMS starts up and loads all plugins.
      def plugin_loaded
      end

      # Override this method to supply a rack app to be used for handling
      # requests. Locomotive CMS will mount this app on a path dependent on the
      # `plugin_id`. See `RackAppHelpers` for some helper methods.
      def rack_app
        nil
      end

    end

    # This variable is set by LocomotiveCMS. It contains the controller which
    # is handling the current request.
    attr_accessor :controller

    # This variable is set by LocomotiveCMS. It contains the current
    # configuration hash for the plugin.
    attr_accessor :config

    # Override this method to provide a liquid drop which should be available
    # in the CMS.
    def to_liquid
      nil
    end

    # Override this method to supply a path to the config UI template file.
    # This file should be an HTML or HAML file using the Handlebars.js
    # templating language.
    def config_template_file
      nil
    end

    # This method may be overridden to supply the raw HTML string to be used
    # for the config UI. The HTML string may be a Handlebars.js template. By
    # default, this method will use the file supplied by the
    # +config_template_file+ method to construct the string (see
    # #config_template_file).
    #
    # @return by default, the contents of +config_template_file+, parsed by
    #         HAML if needed
    def config_template_string
      self.default_config_template_string(self.config_template_file)
    end

  end

end
