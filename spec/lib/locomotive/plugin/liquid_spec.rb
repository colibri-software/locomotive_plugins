
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

      describe 'liquid tags' do

        before(:each) do
          @plugin_class = PluginWithTags
          @prefixed_tags = @plugin_class.prefixed_liquid_tags('prefix')

          @enabled_tags = []
          @context = ::Liquid::Context.new
          @context.registers[:enabled_plugin_tags] = @enabled_tags

          @raw_template = <<-TEMPLATE
            {% prefix_paragraph %}Some Text{% endprefix_paragraph %}
            Some Text{% prefix_newline %}
          TEMPLATE
        end

        it 'supplies the prefixed tag names along with subclasses of the tag classes' do
          @prefixed_tags.size.should == 2
          @prefixed_tags['prefix_paragraph'].should be < PluginWithTags::Paragraph
          @prefixed_tags['prefix_newline'].should be < PluginWithTags::Newline
        end

        it 'only renders a tag if it is enabled in the liquid context' do
          expected_output = <<-TEMPLATE
            <p>Some Text</p>
            Some Text<br />
          TEMPLATE

          register_tags(@prefixed_tags)
          template = ::Liquid::Template.parse(@raw_template)
          template.render(@context).should_not == expected_output

          @enabled_tags << @prefixed_tags['prefix_paragraph']
          @enabled_tags << @prefixed_tags['prefix_newline']
          template.render(@context).should == expected_output
        end

        it 'uses render_disabled or empty string if the plugin is not enabled' do
          expected_output = <<-TEMPLATE
            Some Text
            Some Text
          TEMPLATE

          register_tags(@prefixed_tags)
          template = ::Liquid::Template.parse(@raw_template)
          template.render(@context).should == expected_output
        end

        protected

        def register_tags(tags)
          tags.each do |name, klass|
            ::Liquid::Template.register_tag(name, klass)
          end
        end

      end

    end
  end
end
