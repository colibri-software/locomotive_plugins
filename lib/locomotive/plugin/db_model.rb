
module Locomotive
  module Plugin
    # All classes to be persisted by a plugin should inherit from this class
    # (see Locomotive::Plugin::ClassMethods #has_many or #has_one)
    class DBModel
      include ::Mongoid::Document
    end
  end
end
