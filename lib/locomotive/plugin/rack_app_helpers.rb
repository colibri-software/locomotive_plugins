
module Locomotive
  module Plugin
    # This module adds helpers for handling the Rack app supplied by the
    # +rack_app+ method.
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

      # Methods to be added to the plugin class
      module ClassMethods
        # Gets the Rack app and sets up additional helper methods. This value is memoized
        # and should be used to access the rack_app, rather than calling the
        # +rack_app+ class method directly.
        #
        # @return the Rack app with helper methods or nil if no Rack app is given
        def mounted_rack_app
          @mounted_rack_app ||= self.rack_app.tap do |app|
            if app
              app.extend(HelperMethods)
            end
          end
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

      # Delegates to +ClassMethods#mounted_rack_app+.
      #
      # @return the rack app with the helper methods
      def mounted_rack_app
        self.class.mounted_rack_app
      end

      protected

      def base_uri_object
        URI(mountpoint)
      end

      def set_plugin_object_on_rack_app
        if mounted_rack_app
          old_plugin_object = mounted_rack_app.plugin_object
          begin
            mounted_rack_app.plugin_object = self
            yield
          ensure
            mounted_rack_app.plugin_object = old_plugin_object
          end
        else
          yield
        end
      end

    end
  end
end
