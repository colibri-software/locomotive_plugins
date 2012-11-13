
module Locomotive
  module Plugin
    class DBModelContainer
      include Mongoid::Document

      field :plugin_id

      validates_presence_of :plugin_id
      validates_uniqueness_of :plugin_id
    end
  end
end
