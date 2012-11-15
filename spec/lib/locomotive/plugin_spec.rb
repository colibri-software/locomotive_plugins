
require 'spec_helper'

module Locomotive
  describe Plugin do

    before(:each) do
      @config = {}
      @plugin = MyPlugin.new(@config)
      @another_plugin = MyOtherPlugin.new(@config)
      @useless_plugin = UselessPlugin.new(@config)
    end

    it 'should call custom initialization methods' do
      @plugin.custom_attribute.should == 'Value'
    end

    it 'should store a list of before_filters' do
      @plugin.before_filters.count.should == 2
      @plugin.before_filters[0].should == :my_method1
      @plugin.before_filters[1].should == :my_method2
    end

    it 'should have an empty array of before_filters by default' do
      @useless_plugin.before_filters.should == []
    end

    it 'should optionally return a liquid drop' do
      @plugin.to_liquid.class.should == MyDrop
      @another_plugin.to_liquid.should be_nil
    end

    it 'should optionally return a content type scope' do
      @plugin.content_type_scope('my content type').should == { :my_field => :my_value }
      @another_plugin.content_type_scope('my content type').should be_nil
    end

    it 'should optionally return liquid filters' do
      @plugin.liquid_filters.should == MyPlugin::Filters
      @another_plugin.liquid_filters.should be_nil
    end

    describe 'config UI' do

      it 'should return the template string of an HTML file' do
        filepath = @plugin.config_template_file
        @plugin.config_template_string.should == IO.read(filepath)
      end

      it 'should handle non-string paths' do
        @plugin_with_non_string_path = PluginWithNonStringPath.new(@config)
        filepath = @plugin_with_non_string_path.config_template_file
        template = @plugin_with_non_string_path.config_template_string
        template.should == IO.read(filepath.to_s)
      end

      it 'should return nil for the template string if no file is specified' do
        @useless_plugin.config_template_string.should be_nil
      end

      it 'should compile the template string for a HAML file' do
        filepath = @another_plugin.config_template_file
        haml = IO.read(filepath)
        html = Haml::Engine.new(haml).render
        @another_plugin.config_template_string.should == html
      end

    end

    describe 'DB Models' do

      before(:each) do
        plugin = PluginWithDBModel.new({})
        plugin.build_visit_count(count: 5)
        plugin.items.build(name: 'First Item')
        plugin.items.build(name: 'Second Item')
        plugin.save_db_model_container.should be_true

        # Reload from the database
        @plugin_with_db_model = PluginWithDBModel.new({})
      end

      it 'should persist DBModel items' do
        @plugin_with_db_model.visit_count.count.should == 5

        @plugin_with_db_model.items.count.should == 2
        @plugin_with_db_model.items[0].name.should == 'First Item'
        @plugin_with_db_model.items[1].name.should == 'Second Item'
      end

      it 'should allow mongoid queries on persisted DBModel items' do
        @plugin_with_db_model.items.where(name: /First/).count.should == 1
        @plugin_with_db_model.items.where(name: /First/).first.name.should == 'First Item'

        @plugin_with_db_model.items.where(name: /Item/).count.should == 2
        @plugin_with_db_model.items.where(name: /Item/)[0].name.should == 'First Item'
        @plugin_with_db_model.items.where(name: /Item/)[1].name.should == 'Second Item'
      end

      it 'should embed DBModel items in a document for the plugin class' do
        @plugin_with_db_model.visit_count.db_model_container.kind_of?(
          PluginWithDBModel::DBModelContainer).should be_true
        @plugin_with_db_model.items.first.db_model_container.kind_of?(
          PluginWithDBModel::DBModelContainer).should be_true

        @plugin_with_db_model.visit_count.relations[
          'db_model_container'].relation.should \
          == Mongoid::Relations::Embedded::In
      end

      it 'should run all validations for DBModel items' do
        @plugin_with_db_model.items.build(name: '')
        @plugin_with_db_model.save_db_model_container.should be_false

        @plugin_with_db_model.db_model_container.errors.messages.should == {
          :items => [ 'is invalid' ]
        }
      end

    end

    protected

    def first_drop
      @drop1 ||= MyDrop.new
    end

    def second_drop
      @drop2 ||= MyDrop.new
    end

    class MyPlugin
      include Locomotive::Plugin

      module Filters
      end

      before_filter :my_method1
      before_filter :my_method2

      attr_accessor :custom_attribute

      def initialize_plugin
        self.custom_attribute = 'Value'
      end

      def to_liquid
        MyDrop.new
      end

      def content_type_scope(content_type)
        { :my_field => :my_value }
      end

      def config_template_file
        File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
                  'config_template.html')
      end

      def liquid_filters
        Filters
      end

      def my_method1
        'This is my first before filter!'
      end

      def my_method2
        'This is my second before filter!'
      end
    end

    class MyOtherPlugin
      include Locomotive::Plugin

      before_filter :another_method

      def config_template_file
        File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
                  'config_template.haml')
      end

      def another_method
      end
    end

    class UselessPlugin
      include Locomotive::Plugin
    end

    class MyDrop < ::Liquid::Drop
    end

    class PluginWithNonStringPath

      include Locomotive::Plugin

      class Pathname
        def initialize(path)
          @path = path
        end

        def to_s
          @path.to_s || ''
        end
      end

      def config_template_file
        Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'fixtures',
                  'config_template.html'))
      end

    end

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
end
