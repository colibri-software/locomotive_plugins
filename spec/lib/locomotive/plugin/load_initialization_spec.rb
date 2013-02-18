
require 'spec_helper'

module Locomotive
  module Plugin
    describe LoadInitialization do

      before(:each) do
        MyPlugin.instance_variable_set(:@done_load_inialization, false)
      end

      it 'should call plugin_loaded only once' do
        MyPlugin.custom_attribute.should_not == 'Value'

        MyPlugin.do_load_initialization
        MyPlugin.custom_attribute.should == 'Value'

        -> do
          MyPlugin.do_load_initialization
        end.should raise_error
      end

      it 'should call the given block' do
        expects(:initialization_code)

        MyPlugin.do_load_initialization do
          initialization_code
        end
      end

      it 'should not fail if no plugin_loaded method defined' do
        lambda do
          UselessPlugin.do_load_initialization
        end.should_not raise_error
      end

    end
  end
end
