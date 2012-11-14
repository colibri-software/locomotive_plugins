
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

### Initialization

To initialize a plugin object, do not override the `initialize` method because
this method is defined by the `Locomotive::Plugin` module and used by
Locomotive. Instead, override the `initialize_plugin` method.

    class MyPlugin
      include Locomotive::Plugin

      def initialize_plugin
        # Custom initialization code
      end
    end

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

### Config UI

Plugins can provide a UI for setting configuration attributes. The UI should be
written as a [Handlebars.js](http://handlebarsjs.com/) template. When the
template is rendered, it is supplied with the array of content types in the
CMS. This can be used, for example, to create a select box for selecting a
content type to be acted upon by the plugin.

A config UI can be specified by a plugin in a few ways. The preferred method is
to override the  `config_template_file` method on the plugin class. This method
must return a path to an HTML or HAML file. For more fine-grained control over
how the string is generated, the `config_template_string` can be overridden to
directly supply the HTML string to be rendered.

## Database Models

Plugins can persist data in the database through the use of DBModels. A DBModel
has all the functionality of a Mongoid document. For example:

    class VisitCount < Locomotive::Plugin::DBModel
      field :count, default: 0
    end

    class VisitCounter
      include Locomotive::Plugin

      has_one :visit_count, VisitCount
      before_filter :increment_count

      def increment_count
        build_visit_count unless visit_count
        visit_count.count += 1
      end
    end

## Development

TODO
