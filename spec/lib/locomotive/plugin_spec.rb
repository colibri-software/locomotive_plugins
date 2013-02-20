
require 'spec_helper'

module Locomotive
  describe Plugin do

    before(:each) do
      @plugin = MyPlugin.new
      @useless_plugin = UselessPlugin.new
    end

    %w{page_render rack_app_request}.each do |type|
      it "should have #{type} callbacks" do
        @plugin.expects(:my_method1)
        @plugin.expects(:my_method2)
        @plugin.expects(:my_method3)
        @plugin.run_callbacks(:"#{type}") do
        end
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

    it 'should optionally supply a Rack application' do
      UselessPlugin.new.rack_app.should be_nil
      PluginWithRackApp.new.rack_app.should_not be_nil
    end

  end
end
