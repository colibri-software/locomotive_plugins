
require 'spec_helper'

module Locomotive
  describe Plugin do

    before(:each) do
      @plugin = MyPlugin.new
    end

    it 'should store a list of before_filters' do
      @plugin.before_filters.count.should == 2
      @plugin.before_filters[0].should == :my_method1
      @plugin.before_filters[1].should == :my_method2
    end

    it 'should store a list of liquid drops' do
      @plugin.drops.count.should == 2
      @plugin.drops[0].class.should == @drop1
      @plugin.drops[1].class.should == @drop2
      @plugin.drops[0].should_not == @plugin.drops[1]
    end

    protected

    def first_drop
      @drop1 ||= MyDrop.new
    end

    def second_drop
      @drop2 ||= MyDrop.new
    end

    class MyPlugin
      include Locomotive::Plugin

      before_filter :my_method1
      before_filter :my_method2

      def self.build_drops
        drop first_drop
        drop second_drop
      end

      def my_method1
        'This is my first before filter!'
      end

      def my_method2
        'This is my second before filter!'
      end
    end

    class MyOtherPlugin
      include Locomotive::Plugin

      before_filter :another_method

      def another_method
      end
    end

    class MyDrop < ::Liquid::Drop
    end

  end
end
