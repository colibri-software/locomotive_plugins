
require 'spec_helper'

describe LocomotivePlugins do

  before(:each) do
    LocomotivePlugins.clear_registered_plugins
  end

  it 'should register plugins under a given id' do
    LocomotivePlugins.register_plugin(Locomotive::MyPlugin, 'my_amazing_plugin')
    registered = LocomotivePlugins.registered_plugins
    registered.count.should == 1
    registered['my_amazing_plugin'].should == Locomotive::MyPlugin
  end

  it 'should register plugins under the default id' do
    default_id = LocomotivePlugins.default_id(Locomotive::MyPlugin)
    LocomotivePlugins.register_plugin(Locomotive::MyPlugin)
    registered = LocomotivePlugins.registered_plugins
    registered.count.should == 1
    registered[default_id].should == Locomotive::MyPlugin
  end

  it 'should use the underscorized class name without any modules as the default id' do
    LocomotivePlugins.default_id(Locomotive::MyPlugin).should == 'my_plugin'
  end

  protected

  module Locomotive
    class MyPlugin
      include Locomotive::Plugin
    end
  end

end
