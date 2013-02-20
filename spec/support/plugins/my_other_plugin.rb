
module Locomotive
  class MyOtherPlugin
    include Locomotive::Plugin

    before_page_render :another_method

    def config_template_file
      File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
        'config_template.haml')
    end

    def another_method
    end
  end
end
