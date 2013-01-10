
require 'spec_helper'

module Locomotive
  module Plugin
    describe Liquid do

      context '#setup_liquid_context' do

        before(:each) do
          @config = {}
          @plugin = MyPlugin.new(@config)
          @context = ::Liquid::Context.new({}, {}, {}, true)
          @plugin.setup_liquid_context('my_plugin', @context)
        end

        it 'should add a container for the plugin liquid drops' do
          @context['plugins.my_plugin'].class.should == MyPlugin::MyDrop
        end

        it 'should add a set of enabled liquid tags' do
          @context.registers[:enabled_plugin_tags].class.should == Set
          @context.registers[:enabled_plugin_tags].size.should == 1
          @context.registers[:enabled_plugin_tags].should include(MyPlugin::MyTag::TagSubclass)
        end

        it 'should add liquid filters' do
          @context.strainer.my_plugin_filter('input').should == 'input'
          expect { @context.strainer.language_plugin_filter('input') }.to raise_error
        end

        it 'should add the plugin object to the context when invoking drops' do
          ContextHelpers.expects(:add_plugin_object_to_context).with(
            'my_plugin', @context)
          ::Liquid::Template.parse(
            '{{ plugins.my_plugin.dummy_method }}').render(@context)
        end

        it 'should add the plugin object to the context when calling filters' do
          ContextHelpers.expects(:add_plugin_object_to_context).with(
            'my_plugin', @context)
          ::Liquid::Template.parse(
            '{{ "test" | my_plugin_filter }}').render(@context)
        end

        it 'should add the plugin object to the context when rendering tags' do
          MyPlugin.register_tags('my_plugin')
          ContextHelpers.expects(:add_plugin_object_to_context).with(
            'my_plugin', @context)
          ::Liquid::Template.parse('{% my_plugin_my_tag %}').render(@context)
        end

      end

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

        it 'should give the current liquid context object to the passthrough objects' do
          Locomotive::Plugin::Liquid::PrefixedFilterModule.module_eval do
            attr_reader :context
            def passthrough_objects ; @_passthrough_objects ; end
          end

          # Extend the module and create the passthrough object
          strainer.extend(@plugin_with_filter.prefixed_liquid_filter_module('prefix'))
          strainer.prefix_add_http('google.com').should == 'http://google.com'

          # Find the context of the passthrough object
          obj = strainer.passthrough_objects['prefix']
          def obj.context ; @context ; end

          obj.context.should == strainer.context
        end

      end

      describe 'liquid tags' do

        before(:each) do
          @plugin_class = PluginWithTags
          @prefixed_tags = @plugin_class.prefixed_liquid_tags('prefix')

          # Clear out existing registered liquid tags and register the ones we
          # want
          ::Liquid::Template.instance_variable_set(:@tags, nil)
          PluginWithTags.register_tags('prefix')

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

        it 'should register all prefixed tags in liquid' do
          ::Liquid::Template.tags.size.should == 2
          ::Liquid::Template.tags['prefix_paragraph'].should be \
            < PluginWithTags::Paragraph
          ::Liquid::Template.tags['prefix_newline'].should be \
            < PluginWithTags::Newline
        end

        it 'only renders a tag if it is enabled in the liquid context' do
          expected_output = <<-TEMPLATE
            <p>Some Text</p>
            Some Text<br />
          TEMPLATE

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

          template = ::Liquid::Template.parse(@raw_template)
          template.render(@context).should == expected_output
        end

        it 'uses render_disabled or empty string if no plugin is enabled' do
          @context.registers.delete(:enabled_plugin_tags)

          expected_output = <<-TEMPLATE
            Some Text
            Some Text
          TEMPLATE

          template = ::Liquid::Template.parse(@raw_template)
          template.render(@context).should == expected_output
        end

      end

    end
  end
end
