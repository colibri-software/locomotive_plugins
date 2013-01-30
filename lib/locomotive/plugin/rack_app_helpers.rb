
module Locomotive
  module Plugin
    # This module adds helpers for handling the Rack app supplied by the
    # `rack_app` method.
    module RackAppHelpers

      # Helper methods to be added to the Rack application.
      module HelperMethods
        attr_accessor :plugin_object
        attr_reader :env

        # Set the env on the Rack app so that it can be retrieved later. This
        # method will yield, and then set the env back to what it was after the
        # block returns.
        #
        # @param env the Rack environment
        def with_env(env)
          old_env = @env
          @env = env
          yield
        ensure
          @env = old_env
        end

        # Generate the full absolute path for the given path based on the
        # mountpoint of this plugin's rack app.
        #
        # @param path [String]  the path relative to the mountpoint of the rack
        #                       app
        # @return the absolute path
        def full_path(path)
          [
            base_uri_object.path.sub(%r{/+$}, ''),
            path.sub(%r{^/+}, '')
          ].join('/')
        end

        # Generate the full URL for the given path based on the mountpoint of
        # this plugin's rack app.
        #
        # @param path [String]  the path relative to the mountpoint of the rack
        #                       app
        # @return the URL
        def full_url(path)
          [
            base_uri_object.to_s.sub(%r{/+$}, ''),
            path.sub(%r{^/+}, '')
          ].join('/')
        end

        protected

        def base_uri_object
          request_uri = env['REQUEST_URI']
          base_path = env['SCRIPT_NAME']
          base_uri = request_uri.sub(/(#{base_path}).*$/, '\1')
          URI(base_uri)
        end
      end

      # Wrapper class around the Rack application returned by the plugin class.
      # Acts as middleware to ensure some setup and teardown when the app is
      # called.
      class RackAppWrapper
        # Initialize with the Rack application to wrap.
        #
        # @param app the Rack application
        def initialize(app)
          @app = app
        end

        # Call the underlying Rack app with the given environment.
        #
        # @param env the Rack environment
        def call(env)
          @app.with_env(env) do
            @app.call(env)
          end
        end
      end

      # Adds helper methods to the Rack app and returns another Rack app which
      # wraps it. This method gets the Rack application ready to be called by
      # Locomotive. Locomotive CMS calls this method to get the Rack app rather
      # than calling `rack_app` directly.
      #
      # @return the Rack app with helper methods
      def prepared_rack_app
        app = self.class.rack_app

        if app
          # Extend helper module if needed
          unless app.singleton_class.included_modules.include?(HelperMethods)
            app.extend(HelperMethods)
          end

          app.plugin_object = self
          RackAppWrapper.new(app)
        end
      end

    end
  end
end
