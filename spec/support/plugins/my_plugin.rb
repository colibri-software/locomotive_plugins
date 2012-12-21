
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

    before_filter :my_method1
    before_filter :my_method2

    attr_accessor :custom_attribute

    def initialize_plugin
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
      'This is my first before filter!'
    end

    def my_method2
      'This is my second before filter!'
    end
  end
end
