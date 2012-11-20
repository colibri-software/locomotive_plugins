
Dir.glob(File.join(File.dirname(__FILE__), 'plugin', '**', '*.rb')) do |f|
  require f
end

module Locomotive

  # Include this module in a class which should be registered as a Locomotive
  # plugin
  module Plugin

    include ConfigUI
    include DBModels
    include Liquid

    def self.included(base)
      self.add_db_model_class_methods(base)
      self.add_liquid_tag_methods(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Add a before filter to be called by the underlying controller
      def before_filter(meth)
        @before_filters ||= []
        @before_filters << meth
      end

      # Get list of before filters
      def before_filters
        @before_filters ||= []
      end

      # Override this method to provide a module or array of modules to include
      # as liquid filters in the site. All public methods in the module will be
      # included as filters after being prefixed with the plugin id
      # ({plugin_id}_{method_name})
      def liquid_filters
        nil
      end

      # Override this method to specify the liquid tags supplied by this
      # plugin. The return value must be a hash whose keys are the tag names
      # and values are the tag classes
      def liquid_tags
        {}
      end

      # Create a mongoid relationship to objects of the given class
      def has_many(name, klass)
        self.create_has_many_relationship(name, klass)
      end

      # Create a mongoid relationship to object of the given class
      def has_one(name, klass)
        self.create_has_one_relationship(name, klass)
      end
    end

    # These variables are set by LocomotiveCMS
    attr_accessor :controller, :config

    # Initialize by supplying the current config parameters. Note that this
    # method should not be overridden for custom initialization of plugin
    # objects. Instead, override the initialize_plugin method
    def initialize(config)
      self.config = config
      self.load_or_create_db_model_container!
      self.save_db_model_container
      self.initialize_plugin
    end

    # Override this method to supply custom initialization code for the plugin
    # object
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

    # Override this method to supply the raw HTML string to be used for the
    # config UI. The HTML string may be a Handlebars.js template. By default,
    # this method will use the file supplied by the config_template_file method
    # to construct the string
    def config_template_string
      self.default_config_template_string
    end

  end

end
