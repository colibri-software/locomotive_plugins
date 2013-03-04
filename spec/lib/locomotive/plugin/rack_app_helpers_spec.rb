
require 'spec_helper'

module Locomotive
  module Plugin
    describe RackAppHelpers do

      let(:plugin) { PluginWithRackApp.new }

      let(:mounted_app) { plugin.class.mounted_rack_app }

      before(:each) do
        plugin.class.mountpoint = 'http://www.example.com/my/path/'
        plugin.class.instance_variable_set(:@mounted_rack_app, nil)
      end

      it 'should only supply a Rack app if one has been given' do
        plugin = UselessPlugin.new
        plugin.class.mounted_rack_app.should be_nil
      end

      it 'should supply a mounted app which is equal to the supplied app' do
        mounted_app.should == plugin.class.rack_app
      end

      it 'should add the plugin object to the Rack app' do
        stub_app_call do
          mounted_app.plugin_object.should == plugin
        end

        mounted_app.plugin_object.should be_nil
        mounted_app.call(default_env)
        mounted_app.plugin_object.should be_nil
      end

      it 'should add path and url helpers to the Rack app' do
        mounted_app.respond_to?(:full_path).should be_true
        mounted_app.respond_to?(:full_url).should be_true
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
        app = plugin.class.mounted_rack_app

        plugin = PluginWithRackApp.new
        rack_app = NewRackAppClass.new
        plugin.class.stubs(:rack_app).returns(rack_app)

        app = plugin.class.mounted_rack_app
        rack_app.expects(:extend).with(HelperMethods).never
        app = plugin.class.mounted_rack_app
      end

      it 'should supply an absolute path from the plugin object and the Rack app' do
        path0 = '/plugin/path'
        path1 = 'another//path'

        full_path0 = '/my/path/plugin/path'
        full_path1 = '/my/path/another//path'

        plugin.rack_app_full_path(path0).should == full_path0
        plugin.rack_app_full_path(path1).should == full_path1

        stub_app_call do
          mounted_app.full_path(path0).should == full_path0
          mounted_app.full_path(path1).should == full_path1
        end

        mounted_app.call(default_env)
      end

      it 'should supply a full url from the plugin object and the Rack app' do
        path0 = '/plugin/path'
        path1 = 'another//path'

        full_url0 = 'http://www.example.com/my/path/plugin/path'
        full_url1 = 'http://www.example.com/my/path/another//path'

        plugin.rack_app_full_url(path0).should == full_url0
        plugin.rack_app_full_url(path1).should == full_url1

        stub_app_call do
          mounted_app.full_url(path0).should == full_url0
          mounted_app.full_url(path1).should == full_url1
        end

        mounted_app.call(default_env)
      end

      %w{rack_app_full_path rack_app_full_url mountpoint mounted_rack_app}.each do |meth|
        it "should pass the #{meth} instance method through to the plugin class" do
          args = {
            'rack_app_full_path' => ['/'],
            'rack_app_full_url' => ['/'],
            'mountpoint' => [],
            'mounted_rack_app' => []
          }
          plugin.public_send(meth, *args[meth]).should ==
            plugin.class.public_send(meth, *args[meth])
        end
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
      # `mounted_app.call`, the spec will fail.
      def stub_app_call(&block)
        obj = Object.new
        mounted_app.block = Proc.new do
          obj.the_block_has_been_called
          plugin.run_callbacks(:rack_app_request) do
            block.call
          end
        end
        obj.expects(:the_block_has_been_called).at_least_once
      end

    end
  end
end
