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
        template: "# ARGS
# $1 device_serial_id
# $2 test_server_port
# $3 android_apk
# $4 results dir

export DEVICE_HIVE_GEMFILE_PATH=\"$PWD/Gemfile.hive\"

( cat Gemfile; echo \"source 'http://10.10.11.14:3001'
    gem 'post_result', '0.2.3'\" ) > $DEVICE_HIVE_GEMFILE_PATH

bundle install --gemfile=$DEVICE_HIVE_GEMFILE_PATH

export BUNDLE_GEMFILE=\"$DEVICE_HIVE_GEMFILE_PATH\"
export WORLD_VERSION_ID=<%= version %>
export BATCH_ID=<%= batch_id %>
export RUN_ID=<%= run_id %>
export JOB_ID=<%= job_id %>
export ADB_DEVICE_ARG=$1
export TEST_SERVER_PORT=$2
export SCREENSHOT_PATH=$4
export REINSTALL_APP=1

bundle exec calabash-android run $3 -n \"<%= tests.join('\" -n \"') %>\" -f pretty -o \"$4/pretty.out\" -f TestRail::Submit -o \"$4/test_rail.out\" -f Hive::Submit -o \"$4/hive.out\" -v")

    Project20140311132801.where(execution_type_id: 0).update_all(execution_type_id: execution_type.id)
  end
end
