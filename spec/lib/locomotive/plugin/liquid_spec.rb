
require 'spec_helper'

module Locomotive
  module Plugin
    describe Liquid do

      context '#setup_liquid_context' do

        before(:each) do
          @config = {}
          @plugin = MyPlugin.new(@config)
          @context = ::Liquid::Context.new({}, {}, {site: @site}, true)
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
          helper = Locomotive::Plugin::Liquid::ContextHelpers
          helper.expects(:add_plugin_object_to_context).with('my_plugin', @context)
          @context['plugins.my_plugin.dummy_method']
        end

        # TODO these specs need to be fixed!

=begin

        it 'should add the plugin object to the context when calling filters' do
          obj = Object.new
          obj.extend(Locomotive::Plugin::Liquid::PrefixedFilterModule)
          class << obj
            attr_accessor :context
          end
          obj.context = @context

          helper = Locomotive::Plugins::LiquidContextHelpers
          helper.expects(:add_plugin_object_to_context).with(
            'mobile_detection_plugin', @context)

          obj.send(:filter_method_called, 'mobile_detection_plugin', 'method') do
          end
        end

        it 'should add the plugin object to the context when rendering tags' do
          obj = Object.new
          obj.extend(Locomotive::Plugin::Liquid::TagSubclassMethods)

          helper = Locomotive::Plugins::LiquidContextHelpers
          helper.expects(:add_plugin_object_to_context).with(
            'mobile_detection_plugin', @context)

          obj.send(:rendering_tag, 'mobile_detection_plugin', true, @context) do
          end
        end

        context 'add_plugin_object_to_context' do

          # TODO: make sure stack works
          # TODO: make sure no site works

          before(:each) do
            @helper = Locomotive::Plugins::LiquidContextHelpers
          end

          it 'should add the object to the context' do
            did_yield = false
            @helper.send(:add_plugin_object_to_context,
                'mobile_detection_plugin', @context) do
              did_yield = true
              @context.registers[:plugin_object].class.should == MobileDetectionPlugin
            end
            did_yield.should be_true
            @context.registers[:plugin_object].should be_nil
          end

          it 'should reset the context object' do
            initial_object = 'initial'
            @context.registers[:plugin_object] = initial_object

            did_yield = false
            @helper.send(:add_plugin_object_to_context,
                'mobile_detection_plugin', @context) do
              did_yield = true
              @context.registers[:plugin_object].class.should == MobileDetectionPlugin
            end
            did_yield.should be_true
            @context.registers[:plugin_object].should == initial_object
          end

        end

=end

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

        it 'should call the filter_method_called hook each time a filter is called' do
          # Keep track of how many times filter_method_called is called
          Locomotive::Plugin::Liquid::PrefixedFilterModule.module_eval do
            attr_reader :count, :prefix, :method

            def filter_method_called(prefix, meth)
              @count ||= 0
              @count += 1
              @prefix = prefix
              @method = meth
              yield
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

        it 'should call the rendering_tag hook each time a tag is rendered' do
          TagSubclassMethods.module_eval do
            def rendering_tag(prefix, enabled, context)
              context.registers[:rendering_tag][self.class] = {
                prefix: prefix,
                enabled: enabled
              }
              yield
            end
          end

          expected_output = <<-TEMPLATE
            <p>Some Text</p>
            Some Text
          TEMPLATE

          @context.registers[:rendering_tag] = {}

          register_tags(@prefixed_tags)
          @enabled_tags << @prefixed_tags['prefix_paragraph']
          template = ::Liquid::Template.parse(@raw_template)
          template.render(@context).should == expected_output

          paragraph_class = ::Locomotive::PluginWithTags::Paragraph::TagSubclass
          newline_class = ::Locomotive::PluginWithTags::Newline::TagSubclass

          hash = @context.registers[:rendering_tag]
          hash[paragraph_class].should == { prefix: 'prefix', enabled: true }
          hash[newline_class].should == { prefix: 'prefix', enabled: false }
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
