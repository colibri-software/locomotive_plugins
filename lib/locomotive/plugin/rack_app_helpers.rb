
module Locomotive
  module Plugin
    # This module adds helpers for handling the Rack app supplied by the
    # `rack_app` method.
    module RackAppHelpers

      # Helper methods to be added to the Rack application.
      module HelperMethods
        attr_accessor :plugin_object

        # Generate the full absolute path for the given path based on the
        # mountpoint of this plugin's rack app.
        #
        # @param path [String]  the path relative to the mountpoint of the rack
        #                       app
        # @return the absolute path
        def full_path(path)
          plugin_object.rack_app_full_path(path)
        end

        # Generate the full URL for the given path based on the mountpoint of
        # this plugin's rack app.
        #
        # @param path [String]  the path relative to the mountpoint of the rack
        #                       app
        # @return the URL
        def full_url(path)
          plugin_object.rack_app_full_url(path)
        end
      end

      # The mountpoint of the Rack app.
      #
      # @return the mountpoint
      def mountpoint
        @mountpoint ||= '/'
      end

      # Set the mountpoint of the Rack app.
      #
      # @param mountpoint [String] the new mountpoint
      def mountpoint=(mountpoint)
        @mountpoint = mountpoint
      end

      # Generate the full absolute path within the plugin's rack app for the
      # given path based on the mountpoint.
      #
      # @param path [String]  the path relative to the mountpoint of the rack
      #                       app
      # @return the absolute path
      def rack_app_full_path(path)
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
      def rack_app_full_url(path)
        [
          base_uri_object.to_s.sub(%r{/+$}, ''),
          path.sub(%r{^/+}, '')
        ].join('/')
      end

      # Adds helper methods to the Rack app and returns another Rack app which
      # wraps it. This method gets the Rack application ready to be called by
      # Locomotive. Locomotive CMS calls this method to get the Rack app rather
      # than calling `rack_app` directly.
      #
      # @return the Rack app with helper methods or nil if no Rack app is given
      def prepared_rack_app
        app = self.class.rack_app

        if app
          # Extend helper module if needed
          unless app.singleton_class.included_modules.include?(HelperMethods)
            app.extend(HelperMethods)
          end

          app.plugin_object = self
        end

        app
      end

      protected

      def base_uri_object
        URI(mountpoint)
      end

    end
  end
end
