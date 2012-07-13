
require 'spec_helper'

module Locomotive
  describe Plugin do

    before(:each) do
      @plugin = MyPlugin.new
      @another_plugin = MyOtherPlugin.new
      @useless_plugin = UselessPlugin.new
    end

    it 'should store a list of before_filters' do
      @plugin.before_filters.count.should == 2
      @plugin.before_filters[0].should == :my_method1
      @plugin.before_filters[1].should == :my_method2
    end

    it 'should have an empty array of before_filters by default' do
      @useless_plugin.before_filters.should == []
    end

    it 'should optionally return a liquid drop' do
      @plugin.to_liquid.class.should == MyDrop
      @another_plugin.to_liquid.should be_nil
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

      def to_liquid
        MyDrop.new
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

    class UselessPlugin
      include Locomotive::Plugin
    end

    class MyDrop < ::Liquid::Drop
    end

  end
end
