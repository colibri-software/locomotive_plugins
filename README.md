
# Locomotive Plugins

Create plugins for [Locomotive CMS](http://locomotivecms.com/).


## Installation

TODO


## Usage

To create a plugin, create a class which includes the `Locomotive::Plugin`
module and register it as a plugin:

    class BasicAuth
      include Locomotive::Plugin
    end

    LocomotivePlugins.register_plugin(BasicAuth)

The plugin will automatically be registered under an ID which is its
underscored name, in this case, `basic_auth`. To register it under a
different ID, simply supply the ID in the `register_plugin` call:

    LocomotivePlugins::register_plugin(BasicAuth, 'auth')

### Before filters

A plugin may add a before filter which is run before every page load on the
website being hosted in Locomotive CMS. The before filter has access to the
controller which is being invoked, and a config variable which is set within
the Locomotive UI.

    class BasicAuth
      include Locomotive::Plugin

      before_filter :authenticate

      def authenticate
        if self.config[:use_basic_auth]
          self.controller.authenticate_or_request_with_http_basic do |username, password|
            username = USER_ID && password == PASSWORD
          end
        end
      end
    end

### Liquid

A plugin can add a liquid drop which can be accessed from page templates in
LocomotiveCMS. To do so, override the `to_liquid` method.

Plugin code:

    class BasicAuth
      include Locomotive::Plugin

      def to_liquid
        { :userid => self.get_authenticated_user_id }
      end
    end

Liquid code:

    <p>Your User ID is: {{ plugins.basic_auth }}</p>

This liquid code assumes that the plugin has been registered under the default
ID as described above.

### Content Type Scope

A plugin can provide a scope to be used when looping over a content type. To provide this scope, override the `content_type_scope` method.

    class BasicAuth
      include Locomotive::Plugin

      def content_type_scope(content_type)
        protected_content_type = config[:protected_content_types].include?(content_type.slug)
        logged_in = self.user_logged_in?

        if protected_content_type && !logged_in
          { :safe => true }
        else
          nil
        end
      end
    end

In this example, any content type which has been configured as a "protected"
content type will only display to unauthenticated users if the `safe` field is
`true`.


## Development

TODO
