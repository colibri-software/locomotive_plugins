
Dir.glob(File.join(File.dirname(__FILE__), 'plugin', '**', '*.rb')) do |f|
  require f
end

module Locomotive

  # Include this module in a class which should be registered as a Locomotive
  # plugin. See the documentation for the various methods which can be called
  # or overridden to describe the plugin
  module Plugin

    include ClassTracker
    include ConfigUI
    include Liquid

    # @private
    def self.included(base)
      self.track_plugin_class(base)
      self.add_liquid_tag_methods(base)

      base.class_eval do
        extend ActiveModel::Callbacks
        define_model_callbacks :filter
      end

      base.extend ClassMethods
    end

    module ClassMethods
      # Override this method to provide a module or array of modules to include
      # as liquid filters in the site. All public methods in the module will be
      # included as filters after being prefixed with the plugin id
      # (#\\{plugin_id}_#\\{method_name})
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
      # (#\\{plugin_id}_#\\{tag_name})
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
    end

    # This variable is set by LocomotiveCMS. It contains the controller which
    # is handling the current request
    attr_accessor :controller

    # This variable is set by LocomotiveCMS. It contains the current
    # configuration hash for the plugin
    attr_accessor :config

    # Initialize by supplying the current config parameters. Note that this
    # method should not be overridden for custom initialization of plugin
    # objects. Instead, override the initialize_plugin method. If given a
    # block, the block will be called with `self` as an argument before the
    # `initialize_plugin` method is called. This is used by LocomotiveCMS to
    # perform some custom initialization before the plugin's initialization is
    # called.
    def initialize(config)
      self.config = config
      yield self if block_given?
      self.initialize_plugin
    end

    # Override this method to supply custom initialization code for the plugin
    # object. <b>Do not override the normal +initialize+ method</b>
    def initialize_plugin
    end

    # Get all before filters which have been added to the controller
    def before_filters
      self.class.before_filters
    end

    # Override this method to provide a liquid drop which should be available
    # in the CMS
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
    # #config_template_file)
    def config_template_string
      self.default_config_template_string
    end

  end

end
