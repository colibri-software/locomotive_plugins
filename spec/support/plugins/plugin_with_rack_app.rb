
class PluginWithRackApp
  include Locomotive::Plugin

  def self.rack_app
    Proc.new do
      [200, {'Content-Type' => 'text/html'}, []]
    end
  end
end
