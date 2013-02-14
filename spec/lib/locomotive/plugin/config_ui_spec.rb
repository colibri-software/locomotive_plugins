
require 'spec_helper'

module Locomotive
  module Plugin
    describe ConfigUI do

      before(:each) do
        @config = {}

        @plugin = MyPlugin.new
        @plugin.config = @config

        @plugin_with_non_string_path = PluginWithNonStringPath.new
        @plugin_with_non_string_path.config = @config

        @another_plugin = MyOtherPlugin.new
        @another_plugin.config = @config

        @useless_plugin = UselessPlugin.new
        @useless_plugin.config = @config
      end

      it 'should return the template string of an HTML file' do
        @plugin = MyPlugin.new
        filepath = @plugin.config_template_file
        @plugin.config_template_string.should == IO.read(filepath)
      end

      it 'should handle non-string paths' do
        filepath = @plugin_with_non_string_path.config_template_file
        template = @plugin_with_non_string_path.config_template_string
        template.should == IO.read(filepath.to_s)
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
  end
end
