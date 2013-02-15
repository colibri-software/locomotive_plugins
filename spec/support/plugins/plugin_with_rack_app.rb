
class PluginWithRackApp
  include Locomotive::Plugin

  def rack_app
    RackApp
  end

  class RackApp
    class << self
      attr_accessor :block
    end

    def self.call(env)
      block.call
      [200, {'Content-Type' => 'text/html'}, []]
    end
  end
end
