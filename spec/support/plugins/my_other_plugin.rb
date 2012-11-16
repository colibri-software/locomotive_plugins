
module Locomotive
  class MyOtherPlugin
    include Locomotive::Plugin

    before_filter :another_method

    def config_template_file
      File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
        'config_template.haml')
    end

    def another_method
    end
  end
end
