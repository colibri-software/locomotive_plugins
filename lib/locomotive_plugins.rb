
require 'rubygems'
require 'bundler/setup'
require 'liquid'

require 'locomotive/plugin'

module LocomotivePlugins

  def self.default_id(plugin_class)
    plugin_class.to_s.split('::').last.underscore
  end

  def self.register_plugin(plugin_class, plugin_id = nil)
    @@registered_plugins ||= {}
    plugin_id ||= self.default_id(plugin_class)
    @@registered_plugins[plugin_id] = plugin_class
  end

  def self.registered_plugins
    @@registered_plugins ||= {}
  end

  def self.clear_registered_plugins
    @@registered_plugins = {}
  end

end
