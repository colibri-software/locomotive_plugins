
module Locomotive
  module Plugin
    describe DBModels do

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
  end
end
