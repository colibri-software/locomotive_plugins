
module Locomotive

  # Include this module in a class which should be registered as a Locomotive
  # plugin
  module Plugin

    def self.included(base)
      base.class_eval <<-CODE
        class DBModelContainer < ::Locomotive::Plugin::DBModelContainer
        end

        def self.db_model_container_class
          DBModelContainer
        end
      CODE
      base.extend ClassMethods
    end

    module ClassMethods
      # Add a before filter to be called by the underlying controller
      def before_filter(meth)
        @before_filters ||= []
        @before_filters << meth
      end

      # Get list of before filters
      def before_filters
        @before_filters ||= []
      end

      # Create a mongoid relationship to objects of the given class
      def has_many(name, klass)
        db_model_container_class.embeds_many(name, class_name: klass.to_s,
          inverse_of: :db_model_container)
        klass.embedded_in(:db_model_container,
          class_name: db_model_container_class.to_s, inverse_of: name)

        define_passthrough_methods_to_container(name, "#{name}=")
      end

      # Create a mongoid relationship to object of the given class
      def has_one(name, klass)
        db_model_container_class.embeds_one(name, class_name: klass.to_s,
          inverse_of: :db_model_container)
        klass.embedded_in(:db_model_container,
          class_name: db_model_container_class.to_s, inverse_of: name)

        define_passthrough_methods_to_container(name, "#{name}=",
          "build_#{name}", "create_#{name}")
      end

      # :nodoc:
      def define_passthrough_methods_to_container(*methods)
        class_eval <<-EOF
          %w{#{methods.join(' ')}}.each do |meth|
            define_method(meth) do |*args|
              @db_model_container.send(meth, *args)
            end
          end
        EOF
      end
    end

    # These variables are set by LocomotiveCMS
    attr_accessor :controller, :config

    # Initialize by supplying the current config parameters
    def initialize(config)
      self.config = config
      self.load_or_create_db_model_container!
      self.save_container
    end

    # Get all before filters which have been added to the controller
    def before_filters
      self.class.before_filters
    end

    # Override this method to provide a liquid drop which should be available
    # in the CMS
    def to_liquid
      nil
    end

    # Override this method to provide a scope for the given content type
    def content_type_scope(content_type)
      nil
    end

    # Override this method to supply a path to the config UI template file.
    # This file should be an HTML or HAML file using the Handlebars.js
    # templating language.
    def config_template_file
      nil
    end

    # Override this method to supply the raw HTML string to be used for the
    # config UI. The HTML string may be a Handlebars.js template.
    def config_template_string
      filepath = self.config_template_file

      if filepath
        filepath = filepath.to_s
        if filepath.end_with?('haml')
          Haml::Engine.new(IO.read(filepath)).render
        else
          IO.read(filepath)
        end
      else
        nil
      end
    end

    # Save the DB Model container
    def save_container
      self.db_model_container.save
    end

    # Get the DB Model container
    def db_model_container
      @db_model_container || load_or_create_db_model_container!
    end

    protected

    def load_or_create_db_model_container!
      plugin_id = LocomotivePlugins.registered_plugin_id_for_class(self.class)
      @db_model_container = self.class.db_model_container_class.where(
        plugin_id: plugin_id).first \
        || self.class.db_model_container_class.new(plugin_id: plugin_id)
    end

  end

end
