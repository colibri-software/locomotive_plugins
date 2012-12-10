
module Locomotive
  class PluginWithDBModelRelationships
    include Locomotive::Plugin

    class Teacher < Locomotive::Plugin::DBModel
      field :name
      has_many :students,
        class_name: 'Locomotive::PluginWithDBModelRelationships::Student'
    end

    class Student < Locomotive::Plugin::DBModel
      field :name
      belongs_to :teacher,
        class_name: 'Locomotive::PluginWithDBModelRelationships::Teacher'
    end

    has_many :teachers, Teacher
    has_many :students, Student

  end
end
