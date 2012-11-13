require 'rubygems'
require 'bundler/setup'

require 'liquid'
require 'haml'
require 'mongoid'

require 'locomotive/plugin'
require 'locomotive/plugin/db_model'
require 'locomotive/plugin/db_model_container'

# The overall module for registering plugins
module LocomotivePlugins

  # Get the default ID for the given plugin class
  def self.default_id(plugin_class)
    plugin_class.to_s.split('::').last.underscore
  end

  # Register a plugin class with a given ID. If no ID is given, the default ID
  # is obtained by calling <tt>default_id(plugin_class)</tt>
  def self.register_plugin(plugin_class, plugin_id = nil)
    @@registered_plugins ||= {}
    plugin_id ||= self.default_id(plugin_class)
    @@registered_plugins[plugin_id] = plugin_class
  end

  # Get the hash of registered plugin classes, where the keys are the IDs which
  # were used to register the plugins
  def self.registered_plugins
    @@registered_plugins ||= {}
  end

  # Remove all plugins from the registered list
  def self.clear_registered_plugins
    @@registered_plugins = {}
  end

end
