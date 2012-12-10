
Dir.glob(File.join(File.dirname(__FILE__), 'plugin', '**', '*.rb')) do |f|
  require f
end

module Locomotive

  # Include this module in a class which should be registered as a Locomotive
  # plugin. See the documentation for the various methods which can be called
  # or overridden to describe the plugin
  module Plugin

    include ConfigUI
    include DBModels
    include Liquid

    # @private
    def self.included(base)
      self.add_db_model_class_methods(base)
      self.add_liquid_tag_methods(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Add a before filter to be called by the underlying controller
      #
      # @param meth[Symbol] the method to call
      #
      # @example
      #   before_filter :my_method
      def before_filter(meth)
        @before_filters ||= []
        @before_filters << meth
      end

      # Get list of before filters
      #
      # @return [Array<Symbol>] an array of the method symbols
      def before_filters
        @before_filters ||= []
      end

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

      # Create a +has_many+ mongoid relationship to objects of the given class.
      # The given class should be derived from Locomotive::Plugin::DBModel.
      # This will add the following methods to the plugin object:
      #
      # [#\\{name}]   Returns a list of persisted objects
      #
      # [#\\{name}=]  Setter for the list of persisted objects
      #
      # @param name[String] the name of the relationship
      #
      # @param klass[Class] the class of the objects to be stored
      def has_many(name, klass)
        self.create_has_many_relationship(name, klass)
      end

      # Create a +has_one+ mongoid relationship to an object of the given
      # class.  The given class should be derived from
      # Locomotive::Plugin::DBModel. This will add the following methods to the
      # plugin object:
      #
      # [#\\{name}]         Returns the related object
      #
      # [#\\{name}=]        Setter for the related object
      #
      # [build_#\\{name}]   Builds the related object
      #
      # [create_#\\{name}]  Builds and saves the related object
      #
      # @param name[String] the name of the relationship
      #
      # @param klass[Class] the class of the object to be stored
      def has_one(name, klass)
        self.create_has_one_relationship(name, klass)
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
    # objects. Instead, override the initialize_plugin method
    def initialize(config)
      self.config = config
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
