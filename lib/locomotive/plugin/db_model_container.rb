
module Locomotive
  module Plugin
    # The superclass of the DBModelContainer object for each plugin. This
    # container has the actual relationships to the database objects
    class DBModelContainer
      include Mongoid::Document
    end
  end
end
