
module Locomotive
  class MyPlugin
    include Locomotive::Plugin

    module Filters
      def filter(input)
        input
      end
    end

    class MyDrop < ::Liquid::Drop
    end

    class MyTag < ::Liquid::Tag
    end

    before_page_render :my_method1
    after_page_render :my_method2
    around_page_render :my_method3

    before_rack_app_request :my_method1
    after_rack_app_request :my_method2
    around_rack_app_request :my_method3

    class << self
      attr_accessor :custom_attribute
    end

    def self.plugin_loaded
      self.custom_attribute = 'Value'
    end

    def to_liquid
      MyDrop.new
    end

    def config_template_file
      File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
        'config_template.html')
    end

    def self.liquid_filters
      Filters
    end

    def self.liquid_tags
      { 'my_tag' => MyTag }
    end

    def my_method1
      'This is my before filter!'
    end

    def my_method2
      'This is my after filter!'
    end

    def my_method3
      'This is my around filter!'
    end
  end
end
