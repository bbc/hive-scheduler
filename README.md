# Hive Scheduler

The scheduler component behind the hive, and the main web view.

## Installing

### Pre-requisites

* `git` - Some of the gems are only currently available via Github
* MySQL client libraries - `sudo apt-get install libmysqlclient-dev` on Ubuntu
* A javascript runtime - For example, NodeJS - `sudo apt-get install nodejs` on Ubuntu

### Configuration

Add the following lines to `~/.bashrc` (or equivalent):

```bash
export RAILS_ENV=production
export DATABASE_ADAPTER=mysql2
export DATABASE_ENCODING=utf8
export DATABASE_HOST=your_database_host
export DATABASE_PORT=3306
export DATABASE_POOL=5
export DATABASE_USERNAME=database_username
export DATABASE_PASSWORD=database_password
export DATABASE_NAME=database_name
export ATTACHMENT_STORAGE=filesystem
export ATTACHMENT_STORAGE_PATH_BASE=public
export HIVE_QUEUES=true
```

### Set up database

```bash
./bin/rake db:migrate
./bin/rake db:seed
./bin/rake assets:precompile
```

### Start the server

```bash
rails s
```

## Examples

### Hello world

Go into the 'Execution Types' section and create a new execution type. Select
'Shell Script' as the target platform.
Set the name to 'Hello \<name\>' and in the template box enter:

```bash
# This will use the execution variable 'word'
echo Hello $HIVE_WORD
```

Add a new execution variable called `word` and set the field type to 'String'. Save the execution type.

Go into the 'Projects' section and create a new project. Set the name to
'Hello world' and select the execution type to 'Hello \<name\>'. Select the
'Manual' population mechanism and enter 'world' in the Word field and 'bash'
in the Queues field. Leave all other fields as the defaults. Save the project.

Go into the 'Batches' section and create a new batch. Set the name to 'First
test batch'. Select 'Hello world' as the project and set the version to '1.0'.
Leave all other fields as the defaults. Save the batch.

In the 'Batches' section you will now see the batch you have just created and
by clicking on the name you can see a single job belonging to this batch for
the queue 'bash'. If you have a hive set up to run shell tests on a queue
named 'bash' then this test will be executed and by clicking on the job number
you can view the output.

### Android test

The Android Calabash execution type is set up by default. In the 'Projects'
section create a new project and select 'Android Calabash' as the execution
type. Set the name to 'X Platform Example' and enter the following in the 
repository field:
 
```
git@github.com:calabash/x-platform-example.git
```

Select 'Manual' as the population mechanism and enter 'android-5.1.1' in the
queue field. Click on the 'Add queue' link and enter 'android-4.4.4' in the
new queue field.

**Note;** the hive runner is configured to run tests listed
in queues specified by name. The values entered in these fields should be 
changed as appropriate for the configuration of your hives.

Save the project.

In the 'Batches' section create a new batch and select the project 'X Platform
Example'. Set the name to 'Testing X platform example' and set the version.
Upload the apk, which can be found at

* https://github.com/calabash/x-platform-example/tree/master/prebuilt

Leave all other fields unchanged (the list of queues may be amended as required)
and save the batch. As with the 'Hello world' example, the jobs will run if
hives are set up with devices for the given queues and output can be viewed.
