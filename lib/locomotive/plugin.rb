
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
    end

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

  end
