
module Locomotive
  module Plugin

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def before_filter(meth)
        @before_filters ||= []
        @before_filters << meth
      end

      def before_filters
        @before_filters ||= []
      end
    end

    attr_accessor :controller, :config

    def initialize(config)
      self.config = config
    end

    def before_filters
      self.class.before_filters
    end

    def to_liquid
      nil
    end

    def content_type_scope(content_type)
      nil
    end

  end
end
