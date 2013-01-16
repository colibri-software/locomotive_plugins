
module Locomotive
  module Plugin
    # Tracks classes which include the Locomotive::Plugin module. Also allows
    # external classes to provide a tracker. A tracker is a block which will be
    # called when a class includes Locomotive::Plugin. The class object will be
    # handed into the block as a parameter.
    module ClassTracker

      # Set up class tracking on the module which has included this module.
      # This will set up the following methods:
      #
      # [plugin_classes]  Returns the set of plugin classes which have
      #                   included Locomotive::Plugin
      #
      # [track_plugin_class]  Keeps track of the plugin class which has been
      #                       added. Also calls all plugin trackers
      #
      # [add_plugin_class_tracker]  Add a block which is called when a plugin
      #                             class is tracked. The block will be given
      #                             the class to be tracked
      #
      # @param mod the module to add the tracking to
      def self.included(mod)
        mod.instance_eval do
          @plugin_classes = Set.new
          @trackers = []

          class << self
            attr_reader :plugin_classes
          end

          def track_plugin_class(klass)
            @plugin_classes << klass
            _call_trackers(klass)
          end

          def add_plugin_class_tracker(&block)
            @trackers << block
          end

          private

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
