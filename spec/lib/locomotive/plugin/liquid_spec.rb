
require 'spec_helper'

module Locomotive
  module Plugin
    describe Liquid do

      describe '#prefixed_liquid_filter_module' do

        let(:strainer) { ::Liquid::Strainer.new(::Liquid::Context.new) }

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
          strainer.extend(@plugin_with_filter.prefixed_liquid_filter_module('prefix'))
          strainer.prefix_add_http('google.com').should == 'http://google.com'
          strainer.prefix_add_http('http://google.com').should == 'http://google.com'
        end

        it 'includes multiple filter modules for one plugin' do
          @plugin_with_many_filter_modules = PluginWithManyFilterModules.new({})
          mod = @plugin_with_many_filter_modules.prefixed_liquid_filter_module('prefix')
          mod.public_instance_methods.should include(:prefix_add_newline)
          mod.public_instance_methods.should include(:prefix_remove_http)
        end

        it 'works if multiple prefixed modules are mixed into the same object' do
          @plugin_with_many_filter_modules = PluginWithManyFilterModules.new({})

          strainer.extend(@plugin_with_filter.prefixed_liquid_filter_module('prefix1'))
          strainer.extend(@plugin_with_many_filter_modules.prefixed_liquid_filter_module('prefix2'))

          strainer.prefix1_add_http('google.com').should == 'http://google.com'
          strainer.prefix2_add_newline('google.com').should == "google.com\n"
          strainer.prefix2_remove_http('http://google.com').should == 'google.com'
        end

        it 'should call the filter_method_called hook each time a filter is called' do
          # Keep track of how many times filter_method_called is called
          Locomotive::Plugin::Liquid::PrefixedFilterModule.module_eval do
            attr_accessor :count, :prefix, :method

            def filter_method_called(prefix, meth)
              @count ||= 0
              @count += 1
              @prefix = prefix
              @method = meth
            end
          end

          # Call filter methods
          strainer.extend(@plugin_with_filter.prefixed_liquid_filter_module('prefix'))
          strainer.prefix_add_http('google.com').should == 'http://google.com'
          strainer.prefix_add_http('http://google.com').should == 'http://google.com'

          # Make sure filter_method_called was called as expected
          strainer.count.should == 2
          strainer.prefix.should == 'prefix'
          strainer.method.should == :add_http
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

        it 'uses render_disabled or empty string if no plugin is enabled' do
          @context.registers.delete(:enabled_plugin_tags)

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
