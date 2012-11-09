
module Locomotive

  # Include this module in a class which should be registered as a Locomotive
  # plugin
  module Plugin

    def self.included(base)
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

      # TODO: just a stub
      def has_many(*args)
      end

      # TODO: just a stub
      def has_one(*args)
      end
    end

    # These variables are set by LocomotiveCMS
    attr_accessor :controller, :config

    # Initialize by supplying the current config parameters
    def initialize(config)
      self.config = config
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

    # Override this method to provide a scope for the given content type
    def content_type_scope(content_type)
      nil
    end

    # Override this method to supply a path to the config UI template file.
    # This file should be an HTML or HAML file using the Handlebars.js
    # templating language.
    def config_template_file
      nil
    end

    # Override this method to supply the raw HTML string to be used for the
    # config UI. The HTML string may be a Handlebars.js template.
    def config_template_string
      filepath = self.config_template_file

      if filepath
        filepath = filepath.to_s
        if filepath.end_with?('haml')
          Haml::Engine.new(IO.read(filepath)).render
        else
          IO.read(filepath)
        end
      else
        nil
      end
    end

  end

end
