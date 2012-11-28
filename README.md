
# Locomotive Plugins [![Build Status](https://secure.travis-ci.org/colibri-software/locomotive_plugins.png)](https://secure.travis-ci.org/colibri-software/locomotive_plugins.png)

Create plugins for [Locomotive CMS](http://locomotivecms.com/).


## Installation

To create a Locomotive Plugin, create a ruby gem and then install this gem:


    gem install locomotive_plugins

Alternatively if you're using Bundler, add the following line to your Gemfile:

    gem 'locomotive_plugins'

and run `bundle install`.

To install the plugin in LocomotiveCMS, simply [create a LocomotiveCMS
app](http://doc.locomotivecms.com/installation/getting_started) and add your
plugin gem to the app's Gemfile.


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

See the sections below for usage examples. Also, see the
[documentation](http://rubydoc.info/github/colibri-software/locomotive_plugins/).

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

#### Drops

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

    <p>Your User ID is: {{ plugins.basic_auth.userid }}</p>

This liquid code assumes that the plugin has been registered under the default
ID as described above.

#### Filters

A plugin can add liquid filters:

    module Filters

      def add_http(input)
        if input.start_with?('http://')
          input
        else
          "http://#{input}"
        end
      end

    end

    class MyPlugin
      include Locomotive::Plugin

      def self.liquid_filters
        Filters
      end
    end

Locomotive will automatically prefix the filter with the plugin ID in the
liquid code:

    <a href="{{ page.link | my_plugin_add_http }}">Click here!</a>

#### Tags

A plugin may also supply custom liquid tags. The custom tag class may override
the `render_disabled` method to specify what should be rendered if the plugin
is not enabled. By default, this will be the empty string. For example:

    # Note that Liquid::Block is a subclass of Liquid::Tag
    class Paragraph < Liquid::Block
      def render(context)
        "<p>#{render_all(@nodelist, context)}</p>"
      end

      def render_disabled(context)
        render_all(@nodelist, context)
      end
    end

    class Newline < Liquid::Tag
      def render(context)
        "<br />"
      end
    end

    class MyPlugin
      include Locomotive::Plugin

      def self.liquid_tags
        {
          :paragraph => Paragraph,
          :newline => Newline
        }
      end
    end

Locomotive will automatically prefix the tag with the plugin ID in the liquid
code. Consider the following liquid code:

    {% my_plugin_paragraph %}Some Text{% endmy_plugin_paragraph %}
    Some Text{% my_plugin_newline %}

When `MyPlugin` is enabled, the code will be rendered to:

    <p>Some Text</p>
    Some Text<br />

When `MyPlugin` is disabled, the code will be rendered to:

    Some Text
    Some Text

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

Here's an example of an HTML config file:

    <li>
      <label name="my_plugin_config">My Plugin Config</label>
      <input type="text" name="my_plugin_config">
      <p class="inline-hints">My Hint</p>
    </li>
    <li>
      <label name="content_type_slugs">Content Types</label>
      <select name="content_type_slugs" multiple="multiple">
        {{#each content_types}}
        <option value="{{ this.slug }}"> {{ this.name }}</option>
        {{/each}}
      </select>
    </li>

### Database Models

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
