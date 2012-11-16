
module Locomotive
  class PluginWithNonStringPath

    include Locomotive::Plugin

    class Pathname
      def initialize(path)
        @path = path
      end

      def to_s
        @path.to_s || ''
      end
    end

    def config_template_file
      Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
        'config_template.html'))
    end

  end
end
