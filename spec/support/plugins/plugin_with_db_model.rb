
module Locomotive
  class PluginWithDBModel
    include Locomotive::Plugin

    class VisitCount < Locomotive::Plugin::DBModel
      field :count, default: 0
    end

    class Item < Locomotive::Plugin::DBModel
      field :name
      validates_presence_of :name
    end

    has_one :visit_count, VisitCount
    has_many :items, Item

  end
end
