
require 'spec_helper'

module Locomotive
  module Plugin
    module Liquid
      describe ContextHelpers do

        context '#add_plugin_object_to_context' do

          before(:each) do
            @config = {}
            @plugin = MyPlugin.new(@config)
            @context = ::Liquid::Context.new({}, {}, {site: @site}, true)

            plugin = @plugin
            @context.registers[:site] = stub do
              stubs(:plugin_object_for_id).with('my_plugin').returns(plugin)
            end
          end

          it 'should add the object to the context' do
            did_yield = false
            ContextHelpers.add_plugin_object_to_context('my_plugin', @context) do
              did_yield = true
              @context.registers[:plugin_object].should == @plugin
            end
            did_yield.should be_true
            @context.registers[:plugin_object].should be_nil
          end

          it 'should reset the context object' do
            initial_object = 'initial'
            @context.registers[:plugin_object] = initial_object

            did_yield = false
            ContextHelpers.add_plugin_object_to_context('my_plugin', @context) do
              did_yield = true
              @context.registers[:plugin_object].should == @plugin
            end
            did_yield.should be_true
            @context.registers[:plugin_object].should == initial_object
          end

          it 'should do nothing if there is no site object in the context' do
            @context.registers[:site] = nil

            did_yield = false
            ContextHelpers.add_plugin_object_to_context('my_plugin', @context) do
              did_yield = true
              @context.registers[:plugin_object].should be_nil
            end
            did_yield.should be_true
            @context.registers[:plugin_object].should be_nil
          end

          it 'should do nothing if the site object has no plugin_object_for method' do
            @context.registers[:site] = Object.new

            did_yield = false
            ContextHelpers.add_plugin_object_to_context('my_plugin', @context) do
              did_yield = true
              @context.registers[:plugin_object].should be_nil
            end
            did_yield.should be_true
            @context.registers[:plugin_object].should be_nil
          end

        end

      end

    end
  end
end
