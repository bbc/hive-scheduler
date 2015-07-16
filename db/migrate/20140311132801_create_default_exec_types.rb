class CreateDefaultExecTypes < ActiveRecord::Migration

  class ExecutionType20140311132801 < ActiveRecord::Base
    self.table_name = :execution_types
  end

  class Project20140311132801 < ActiveRecord::Base
    self.table_name = :projects
  end

  def change
    ExecutionType20140311132801.reset_column_information
    execution_type = ExecutionType20140311132801.create(
        name:     "Android Calabash",
        template: <<TEMPLATE
export JOB_ID=$HIVE_JOB_ID
echo "gem 'post_result', '0.5.1.pre'" >> Gemfile
bundle install
calabash-android resign $APK_PATH
bundle exec calabash-android run $APK_PATH -p android -f Hive::Submit -o \"$HIVE_RESULTS/hive.out\" -f pretty -o \"$HIVE_RESULTS/pretty.out\"
TEMPLATE
    )

    Project20140311132801.where(execution_type_id: 0).update_all(execution_type_id: execution_type.id)
  end
end
