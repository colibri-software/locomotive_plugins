
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

      it 'should allow relationships between DBModels' do
        plugin = PluginWithDBModelRelationships.new({})

        t1 = plugin.teachers.build(name: 'Mr. Adams')
        t2 = plugin.teachers.build(name: 'Ms. Boudreau')

        s1 = plugin.students.build(name: 'Alex', teacher: t1)
        s2 = plugin.students.build(name: 'Billy', teacher: t1)
        s3 = plugin.students.build(name: 'Caitlyn', teacher: t2)

        plugin.save_db_model_container.should be_true

        # Reload from database
        plugin = PluginWithDBModelRelationships.new({})

        # Check all the names and relationships to make sure they were
        # persisted
        teachers = plugin.teachers.to_a
        students = plugin.students.to_a

        teachers[0].name.should == 'Mr. Adams'
        teachers[0].students.count.should == 2
        teachers[0].students.should include(s1)
        teachers[0].students.should include(s2)

        teachers[1].name.should == 'Ms. Boudreau'
        teachers[1].students.count.should == 1
        teachers[1].students.should include(s3)

        s1.name.should == 'Alex'
        s1.teacher.should == t1
        s2.name.should == 'Billy'
        s2.teacher.should == t1
        s3.name.should == 'Caitlyn'
        s3.teacher.should == t2
      end

    end
  end
end
