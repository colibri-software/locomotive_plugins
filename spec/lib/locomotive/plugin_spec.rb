
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

    it 'should store a list of liquid drops'

    protected

    class MyPlugin
      include Locomotive::Plugin

      before_filter :my_method1
      before_filter :my_method2

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

  end
end
