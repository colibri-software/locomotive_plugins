
require 'spec_helper'

module Locomotive
  module Plugin
    describe LoadInitialization do

      it 'should call plugin_loaded only once' do
        MyPlugin.custom_attribute.should_not == 'Value'

        MyPlugin.do_load_initialization
        MyPlugin.custom_attribute.should == 'Value'

        -> do
          MyPlugin.do_load_initialization
        end.should raise_error
      end

    end
  end
end
