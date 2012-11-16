
require 'spec_helper'

module Locomotive
  module Plugin
    describe Liquid do

      describe '#prefixed_liquid_filter_module' do

        before(:each) do
          @plugin_with_filter = PluginWithFilter.new({})
        end

        it 'should contain all prefixed methods for provided filter modules' do
          mod = @plugin_with_filter.prefixed_liquid_filter_module('prefix')
          mod.public_instance_methods.should include(:prefix_add_http)
        end

        it 'should not contain any of the original methods' do
          mod = @plugin_with_filter.prefixed_liquid_filter_module('prefix')
          mod.public_instance_methods.should_not include(:add_http)
        end

        it 'the prefixed methods should pass through to the original methods' do
          obj = Object.new
          obj.extend(@plugin_with_filter.prefixed_liquid_filter_module('prefix'))
          obj.prefix_add_http('google.com').should == 'http://google.com'
          obj.prefix_add_http('http://google.com').should == 'http://google.com'
        end

      end

    end
  end
end
