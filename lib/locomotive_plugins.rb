require 'rubygems'
require 'bundler/setup'

require 'liquid'
require 'haml'
require 'mongoid'

require 'locomotive/plugin'

# The overall module for registering plugins
module LocomotivePlugins

  # Get the default ID for the given plugin class
  #
  # @param plugin_class[Class] the class of the plugin object
  def self.default_id(plugin_class)
    plugin_class.to_s.split('::').last.underscore
  end

  # Register a plugin class with a given ID. If no ID is given, the default ID
  # is obtained by calling <tt>default_id(plugin_class)</tt>
  #
  # @param plugin_class[Class] the class pf the plugin to register
  # @param plugin_id[String] the plugin ID to use
  def self.register_plugin(plugin_class, plugin_id = nil)
    @@registered_plugins ||= {}
    plugin_id ||= self.default_id(plugin_class)
    @@registered_plugins[plugin_id] = plugin_class
  end

  # Get the hash of registered plugin classes, where the keys are the IDs which
  # were used to register the plugins
  #
  # @return [Hash<String, Class>] a hash of plugin IDs to plugin classes
  def self.registered_plugins
    @@registered_plugins ||= {}
  end

  # Remove all plugins from the registered list
  def self.clear_registered_plugins
    @@registered_plugins = {}
  end

end
