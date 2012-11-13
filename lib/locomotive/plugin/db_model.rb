
module Locomotive
  module Plugin
    # All classes to be persisted by a plugin should inherit from this class
    class DBModel
      include ::Mongoid::Document
    end
  end
end
