
module Locomotive
  module Plugin
    # The superclass of the DBModelContainer object for each plugin. This
    # container has the actual relationships to the database objects
    class DBModelContainer
      include Mongoid::Document

      field :container_name

      def self.for_name(container_name)
        where(container_name: container_name).first || \
          new(container_name: container_name)
      end

    end
  end
end
