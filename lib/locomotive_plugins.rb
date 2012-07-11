
require 'rubygems'
require 'bundler/setup'
require 'liquid'

require 'locomotive/plugin'

module LocomotivePlugins

  def self.register_plugin(plugin_class, plugin_id = nil)
    @@registered_plugins ||= {}
    plugin_id ||= plugin_class.to_s.split('::').last.underscore
    @@registered_plugins[plugin_id] = plugin_class.new
  end

  def self.registered_plugins
    @@registered_plugins ||= {}
  end

  def self.clear_registered_plugins
    @@registered_plugins = {}
  end

end
