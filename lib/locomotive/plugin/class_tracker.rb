
module Locomotive
  module Plugin
    # @private
    # Tracks classes which include the Locomotive::Plugin module. Also allows
    # external classes to provide a tracker. A tracker is a block which will be
    # called when a class includes Locomotive::Plugin. The class object will be
    # handed into the block as a parameter.
    module ClassTracker

      def self.included(mod)
        mod.instance_eval do
          @plugin_classes = Set.new
          @trackers = []

          class << self
            attr_reader :plugin_classes
          end

          def track_plugin_class(klass)
            @plugin_classes << klass
            self._call_trackers(klass)
          end

          # Used by Locomotive CMS to make sure that plugins are loaded
          # properly
          def add_plugin_class_tracker(&block)
            @trackers << block
          end

          protected

          def _call_trackers(klass)
            @trackers.each do |tracker|
              tracker.call(klass)
            end
          end
        end
      end

    end
  end
end
