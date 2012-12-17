
require 'spec_helper'

module Locomotive
  module Plugin
    describe ClassTracker do

      it 'tracks all the classes which include the module' do
        classes = Locomotive::Plugin.plugin_classes
        classes.should include(MyPlugin)
        classes.should include(UselessPlugin)
      end

      it 'supports custom trackers' do
        added_classes = []
        num_added_classes = 0

        Locomotive::Plugin.add_plugin_class_tracker do |plugin_class|
          added_classes << plugin_class
        end

        Locomotive::Plugin.add_plugin_class_tracker do |plugin_class|
          num_added_classes += 1
        end

        c = Class.new { include Locomotive::Plugin }
        added_classes.should == [c]
        num_added_classes.should == 1
      end

    end
  end
end
