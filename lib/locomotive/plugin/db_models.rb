
module Locomotive
  module Plugin
    module DBModels

      def self.included(base)
        base.extend ClassMethods
      end

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

      module DBModelClassMethods

        protected

        def create_has_many_relationship(name, klass)
          self.db_model_container_class.embeds_many(name,
            class_name: klass.to_s, inverse_of: :db_model_container)
          klass.embedded_in(:db_model_container,
            class_name: db_model_container_class.to_s, inverse_of: name)

          self.define_passthrough_methods_to_container(name, "#{name}=")
        end

        def create_has_one_relationship(name, klass)
          self.db_model_container_class.embeds_one(name,
            class_name: klass.to_s, inverse_of: :db_model_container)
          klass.embedded_in(:db_model_container,
            class_name: db_model_container_class.to_s, inverse_of: name)

          self.define_passthrough_methods_to_container(name, "#{name}=",
            "build_#{name}", "create_#{name}")
        end

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

      # Save the DB Model container
      def save_db_model_container
        self.db_model_container.save
      end

      # Get the DB Model container
      def db_model_container
        @db_model_container || load_or_create_db_model_container!
      end

      protected

      def load_or_create_db_model_container!
        @db_model_container = self.class.db_model_container_class.first \
          || self.class.db_model_container_class.new
      end

    end
  end
end
