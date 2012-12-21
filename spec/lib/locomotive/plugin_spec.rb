
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

    it 'should call the given block before custom initialization methods' do
      @plugin = MyPlugin.new(@config) do |obj|
        obj.custom_attribute.should be_nil
      end
      @plugin.custom_attribute.should_not be_nil
    end

    it 'should have filter callbacks' do
      @plugin.expects(:my_method1)
      @plugin.expects(:my_method2)
      @plugin.expects(:my_method3)
      @plugin.run_callbacks(:filter) do
      end
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
      UselessPlugin.liquid_tags.should == {}
      PluginWithTags.liquid_tags.should == {
        :paragraph => PluginWithTags::Paragraph,
        :newline => PluginWithTags::Newline
      }
    end

  end
end
