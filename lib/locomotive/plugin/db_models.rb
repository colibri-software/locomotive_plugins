
module Locomotive
  module Plugin

    # Utility methods for dealing with DB Models
    module DBModels

      # @private
      def self.included(base)
        base.extend ClassMethods
      end

      # @private
      module ClassMethods

        def add_db_model_class_methods(base)
          base.class_eval <<-CODE
            class DBModelContainer < ::Locomotive::Plugin::DBModelContainer
            end

            def self.db_model_container_class
              DBModelContainer
            end
          CODE
          base.extend DBModelClassMethods
        end

      end

      # @private
      module DBModelClassMethods

        protected

        def create_has_many_relationship(name, klass)
          self.db_model_container_class.has_many(name,
            class_name: klass.to_s, inverse_of: :db_model_container,
            autosave: true, dependent: :destroy)
          klass.belongs_to(:db_model_container,
            class_name: db_model_container_class.to_s, inverse_of: name)

          self.define_passthrough_methods_to_container(name, "#{name}=",
            "#{name}_ids", "#{name}_ids=")
        end

        def create_has_one_relationship(name, klass)
          self.db_model_container_class.has_one(name,
            class_name: klass.to_s, inverse_of: :db_model_container,
            autosave: true, dependent: :destroy)
          klass.belongs_to(:db_model_container,
            class_name: db_model_container_class.to_s, inverse_of: name)

          self.define_passthrough_methods_to_container(name, "#{name}=",
            "build_#{name}", "create_#{name}")
        end

        def define_passthrough_methods_to_container(*methods)
          class_eval do
            methods.each do |meth|
              define_method(meth) do |*args|
                db_model_container.send(meth, *args)
              end
            end
          end
        end

      end

      # Save the DB Model container
      def save_db_model_container
        self.db_model_container.save
      end

      # Get the DB Model container
      def db_model_container
        @db_model_containers ||= {}
        name = self.current_db_model_container_name
        @db_model_containers[name] ||= load_db_model_container(name)
      end

      # Set the current DB Model container
      def use_db_model_container(name)
        @current_db_model_container_name = name
      end

      # Reset to the default DB Model container
      def reset_current_db_model_container
        self.use_db_model_container(nil)
      end

      # Set the current DB Model container for the duration of the block
      def with_db_model_container(name, &block)
        old_name = self.current_db_model_container_name
        self.use_db_model_container(name)
        block.call
        self.use_db_model_container(old_name)
      end

      # The name of the current container being used
      attr_reader :current_db_model_container_name

      protected

      def load_db_model_container(name)
        self.class.db_model_container_class.for_name(name)
      end

    end

  end
end
