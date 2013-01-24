
module Locomotive
  module Plugin
    # This module adds helpers for handling the Rack app supplied by the
    # `rack_app` method.
    module RackAppHelpers

      # @private
      #
      # Add class methods.
      #
      # @param base the class which includes this module
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @api internal
      module ClassMethods
        # Adds methods from RackAppHelpersClassMethods module.
        #
        # @param base the plugin class to extend LiquidClassMethods
        def add_rack_app_helper_methods(base)
          base.extend(RackAppHelpersClassMethods)
        end
      end

      # This module adds class methods for managing the mount point for the
      # Rack App. The mount point must be set in order to properly generate
      # paths and URLs.
      module RackAppHelpersClassMethods
        # Set the full URL mountpoint for the Rack app. This will be set by
        # Locomotive CMS. The URL must be an HTTP or HTTPS url with no query
        # parameters or hash fragments.
        #
        # @param url [String] the full URL that the Rack app is mounted on
        def set_mountpoint(url)
          error = lambda do |msg|
            raise Error, "Invalid mountpoint: #{msg}"
          end

          uri = URI(url)
          unless uri.scheme =~ /^https?$/
            error.call('only http or https allowed')
          end
          if uri.fragment
            error.call('no hash fragment allowed')
          end
          if uri.query
            error.call('no query string allowed')
          end

          @mountpoint = uri
        end

        # Get the mountpoint for this plugin class's Rack app.
        #
        # @return the mountpoint
        def mountpoint
          @mountpoint
        end
      end

      # Generate the full absolute path for the given path based on the
      # mountpoint of this plugin's rack app.
      #
      # @param path [String]  the path relative to the mountpoint of the rack
      #                       app
      # @return the absolute path
      def full_path(path)
        [ mountpoint.path.sub(%r{/+$}, ''), path.sub(%r{^/+}, '') ].join('/')
      end

      # Generate the full URL for the given path based on the mountpoint of
      # this plugin's rack app.
      #
      # @param path [String]  the path relative to the mountpoint of the rack
      #                       app
      # @return the URL
      def full_url(path)
        [ mountpoint.to_s.sub(%r{/+$}, ''), path.sub(%r{^/+}, '') ].join('/')
      end

      # Get the mountpoint for this plugin's Rack app.
      #
      # @return the mountpoint
      def mountpoint
        self.class.mountpoint
      end

    end
  end
end
