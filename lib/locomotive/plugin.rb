
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
        @before_filters
      end

      def drop(drop)
        @drops ||= []
        @drops << drop
      end

      def drops
        if !@drops && self.respond_to?(:build_drops)
          build_drops
        end
        @drops ||= []
      end
    end

    def before_filters
      self.class.before_filters
    end

    def drops
      self.class.drops
    end

  end
end
