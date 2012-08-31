
require 'spec_helper'

module Locomotive
  describe Plugin do

    before(:each) do
      @config = {}
      @plugin = MyPlugin.new(@config)
      @another_plugin = MyOtherPlugin.new(@config)
      @useless_plugin = UselessPlugin.new(@config)
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

    it 'should optionally return a content type scope' do
      @plugin.content_type_scope('my content type').should == { :my_field => :my_value }
      @another_plugin.content_type_scope('my content type').should be_nil
    end

    describe 'config UI' do

      it 'should return the template string of an HTML file' do
        filepath = @plugin.config_template_file
        @plugin.config_template_string.should == IO.read(filepath)
      end

      it 'should return nil for the template string if no file is specified' do
        @useless_plugin.config_template_string.should be_nil
      end

      it 'should compile the template string for a HAML file' do
        filepath = @another_plugin.config_template_file
        haml = IO.read(filepath)
        html = Haml::Engine.new(haml).render
        @another_plugin.config_template_string.should == html
      end

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

      def content_type_scope(content_type)
        { :my_field => :my_value }
      end

      def config_template_file
        File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
                  'config_template.html')
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

      def config_template_file
        File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
                  'config_template.haml')
      end

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
