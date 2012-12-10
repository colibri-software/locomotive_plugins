
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

      it 'should reference DBModel items in a document for the plugin class' do
        @plugin_with_db_model.visit_count.db_model_container.kind_of?(
          PluginWithDBModel::DBModelContainer).should be_true
        @plugin_with_db_model.items.first.db_model_container.kind_of?(
          PluginWithDBModel::DBModelContainer).should be_true

        @plugin_with_db_model.visit_count.relations[
          'db_model_container'].relation.should \
          == Mongoid::Relations::Referenced::In
        @plugin_with_db_model.items.relations[
          'db_model_container'].relation.should \
          == Mongoid::Relations::Referenced::In
      end

      it 'should run all validations for DBModel items' do
        @plugin_with_db_model.items.build(name: '')
        @plugin_with_db_model.save_db_model_container.should be_false

        @plugin_with_db_model.db_model_container.errors.messages.should == {
          :items => [ 'is invalid' ]
        }
      end

      it 'should destroy the contained objects when the container is destroyed' do
        vc = @plugin_with_db_model.visit_count
        i0 = @plugin_with_db_model.items[0]
        i1 = @plugin_with_db_model.items[1]

        DBModel.all.for_ids(vc.id, i0.id, i1.id).count.should == 3

        @plugin_with_db_model.db_model_container.destroy

        DBModel.all.for_ids(vc.id, i0.id, i1.id).count.should == 0
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

      context 'with multiple containers' do

        it 'should save the data in the correct container' do
          plugin = PluginWithDBModel.new({})

          plugin.with_db_model_container('my_container') do
            plugin.build_visit_count(count: 10)
          end

          plugin.use_db_model_container('my_other_container')
          plugin.build_visit_count(count: 20)
          plugin.save_db_model_container.should be_true
          plugin.reset_current_db_model_container

          plugin.use_db_model_container('my_container')
          plugin.db_model_container.changed?.should be_true
          plugin.save_db_model_container.should be_true
          plugin.db_model_container.changed?.should be_false

          # Reload from the database
          @plugin_with_db_model = PluginWithDBModel.new({})

          # Make sure everything is in the right container and make sure we can
          # access the containers how we want
          @plugin_with_db_model.with_db_model_container('my_other_container') do
            @plugin_with_db_model.current_db_model_container_name.should ==
              'my_other_container'
            @plugin_with_db_model.visit_count.count.should == 20
          end

          @plugin_with_db_model.use_db_model_container('my_container')
          @plugin_with_db_model.current_db_model_container_name.should ==
            'my_container'
          @plugin_with_db_model.visit_count.count.should == 10

          @plugin_with_db_model.reset_current_db_model_container
          @plugin_with_db_model.current_db_model_container_name.should be_nil
          @plugin_with_db_model.visit_count.count.should == 5
        end

        it 'should revert the current container name after using with_db_model_container' do
          @plugin_with_db_model.use_db_model_container('fake_container')
          @plugin_with_db_model.current_db_model_container_name.should ==
            'fake_container'

          @plugin_with_db_model.with_db_model_container('my_container') do
            @plugin_with_db_model.current_db_model_container_name.should ==
              'my_container'
          end

          @plugin_with_db_model.current_db_model_container_name.should ==
            'fake_container'
        end

        it 'should only load each container once' do
          container_names = %w{my_container my_other_container}

          # The default container has already been loaded
          @plugin_with_db_model.expects(:load_db_model_container).with(nil).never

          # The others should only be called once. Just return something
          # non-nil
          container_names.each do |name|
            @plugin_with_db_model.expects(:load_db_model_container).with(
              name).returns(1).once
          end

          3.times do
            container_names.each do |name|
              @plugin_with_db_model.with_db_model_container(name) do
                # Access the container
                @plugin_with_db_model.db_model_container
              end
            end
          end
        end

        it 'should not share containers between plugin objects' do
          p0 = PluginWithDBModel.new({})
          p1 = PluginWithDBModelRelationships.new({})

          # Default container
          p0.save_db_model_container.should be_true
          p1.save_db_model_container.should be_true
          p0.db_model_container.should_not == p1.db_model_container

          # Named container
          p0.with_db_model_container('my_container') do
            p1.with_db_model_container('my_container') do
              p0.save_db_model_container.should be_true
              p1.save_db_model_container.should be_true
              p0.db_model_container.should_not == p1.db_model_container
            end
          end
        end

      end

    end
  end
end
