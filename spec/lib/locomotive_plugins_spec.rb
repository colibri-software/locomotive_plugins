
require 'spec_helper'

describe LocomotivePlugins do

  before(:each) do
    LocomotivePlugins.clear_registered_plugins
  end

  it 'should register plugins under a given name' do
    LocomotivePlugins.register_plugin(Locomotive::MyPlugin, 'my_amazing_plugin')
    registered = LocomotivePlugins.registered_plugins
    registered.count.should == 1
    registered['my_amazing_plugin'].class.should == Locomotive::MyPlugin
  end

  it 'should register plugins under a default name' do
    LocomotivePlugins.register_plugin(Locomotive::MyPlugin)
    registered = LocomotivePlugins.registered_plugins
    registered.count.should == 1
    registered['my_plugin'].class.should == Locomotive::MyPlugin
  end

  protected

  module Locomotive
    class MyPlugin
      include Locomotive::Plugin
    end
  end

end
