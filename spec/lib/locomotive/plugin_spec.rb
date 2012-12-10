
require 'spec_helper'

module Locomotive
  describe Plugin do

    before(:each) do
      @config = {}
      @plugin = MyPlugin.new(@config)
      @useless_plugin = UselessPlugin.new(@config)
    end

    it 'should call custom initialization methods' do
      @plugin.custom_attribute.should == 'Value'
    end

    it 'should call the gven block before custom initialization methods' do
      @plugin = MyPlugin.new(@config) do |obj|
        obj.custom_attribute.should be_nil
      end
      @plugin.custom_attribute.should_not be_nil
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
      @plugin.to_liquid.class.should == MyPlugin::MyDrop
      @useless_plugin.to_liquid.should be_nil
    end

    it 'should optionally return liquid filters' do
      MyPlugin.liquid_filters.should == MyPlugin::Filters
      UselessPlugin.liquid_filters.should be_nil
    end

    it 'should optionally return liquid tags' do
      MyPlugin.liquid_tags.should == {}
      PluginWithTags.liquid_tags.should == {
        :paragraph => PluginWithTags::Paragraph,
        :newline => PluginWithTags::Newline
      }
    end

  end
end
