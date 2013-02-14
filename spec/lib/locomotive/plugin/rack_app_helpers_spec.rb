
require 'spec_helper'

module Locomotive
  module Plugin
    describe RackAppHelpers do

      let(:plugin) { PluginWithRackApp.new }

      let(:prepared_app) { plugin.prepared_rack_app }

      let(:original_app) { plugin.class.rack_app }

      it 'should only supply a Rack app if one has been given' do
        plugin = UselessPlugin.new
        plugin.prepared_rack_app.should be_nil
      end

      it 'should add the plugin object to the Rack app' do
        stub_app_call do
          original_app.plugin_object.should == plugin
        end

        prepared_app.call(default_env)
      end

      it 'should add the Rack environment to the Rack app' do
        stub_app_call do
          original_app.env.should == default_env
        end

        prepared_app.call(default_env)
      end

      it 'should add path and url helpers to the Rack app' do
        original_app.respond_to?(:full_path).should be_true
        original_app.respond_to?(:full_url).should be_true
      end

      it 'should not add the helper methods if they have already been added' do
        NewRackAppClass = Class.new do
          def method_missing(*args)
          end
        end

        plugin = PluginWithRackApp.new
        rack_app = NewRackAppClass.new
        plugin.class.stubs(:rack_app).returns(rack_app)

        rack_app.expects(:extend).with(HelperMethods)
        app = plugin.prepared_rack_app

        plugin = PluginWithRackApp.new
        rack_app = NewRackAppClass.new
        plugin.class.stubs(:rack_app).returns(rack_app)

        app = plugin.prepared_rack_app
        rack_app.expects(:extend).with(HelperMethods).never
        app = plugin.prepared_rack_app
      end

      it 'should supply an absolute path' do
        stub_app_call do
          original_app.full_path('/plugin/path').should == '/my/path/plugin/path'
          original_app.full_path('another//path').should == '/my/path/another//path'
        end

        prepared_app.call(default_env)
      end

      it 'should supply a full url' do
        stub_app_call do
          original_app.full_url('/plugin/path').should ==
            'http://www.example.com/my/path/plugin/path'
          original_app.full_url('another//path').should ==
            'http://www.example.com/my/path/another//path'
        end

        prepared_app.call(default_env)
      end

      protected

      def default_env
        {
          'REQUEST_URI' => 'http://www.example.com/my/path/request/path',
          'SCRIPT_NAME' => '/my/path'
        }
      end

      # Sets up an object which expects the method `the_block_has_been_called`
      # to be invoked. This way, if you stub the app call but do not call
      # `prepared_app.call`, the spec will fail.
      def stub_app_call(&block)
        obj = Object.new
        original_app.block = Proc.new do
          obj.the_block_has_been_called
          block.call
        end
        obj.expects(:the_block_has_been_called).at_least_once
      end

    end
  end
end
