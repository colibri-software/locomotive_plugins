
require 'spec_helper'

module Locomotive
  module Plugin
    describe RackAppHelpers do

      before(:all) do
        PluginWithRackApp.set_mountpoint('http://www.example.com/my/path')
      end

      before(:each) do
        @config = {}
        @plugin = PluginWithRackApp.new(@config)
      end

      it 'should supply an absolute path based on where it is mounted' do
        @plugin.full_path('/plugin/path').should == '/my/path/plugin/path'
        @plugin.full_path('another//path').should == '/my/path/another//path'
      end

      it 'should supply a full URL based on where it is mounted' do
        @plugin.full_url('/plugin/path').should ==
          'http://www.example.com/my/path/plugin/path'
        @plugin.full_url('another//path').should ==
          'http://www.example.com/my/path/another//path'
      end

      it 'should only allow URLs with proper format' do
        old_mountpoint = PluginWithRackApp.mountpoint

        bad_mountpoints = [
          'my/path',
          'my.server.com/my/path',
          'ftp://my.server.com',
          'http://my.server.com/my/path?q=value',
          'http://my.server.com/my/path#fragment',
          'https://my.server.com/my/path?q=value',
          'https://my.server.com/my/path#fragment'
        ]

        good_mountpoints = [
          'http://my.server.com/my/path',
          'http://my.server.com:3000/my/path',
          'https://my.server.com/my/path',
          'https://my.server.com:3000/my/path'
        ]

        bad_mountpoints.each do |mountpoint|
          lambda do
            PluginWithRackApp.set_mountpoint(mountpoint)
          end.should raise_exception(Locomotive::Plugin::Error)
          PluginWithRackApp.mountpoint.should == old_mountpoint
        end

        good_mountpoints.each do |mountpoint|
          lambda do
            PluginWithRackApp.set_mountpoint(mountpoint)
          end.should_not raise_exception
          PluginWithRackApp.mountpoint.to_s.should == mountpoint
        end
      end

    end
  end
end
