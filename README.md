=Hive Scheduler

The scheduler component behind the hive, and the main web view.

== Installing

=== Pre-requisites

* `git` - Some of the gems are only currently available via Github
* MySQL client libraries - `sudo apt-get install libmysqlclient-dev` on Ubuntu
* A javascript runtime - For example, NodeJS - `sudo apt-get install nodejs` on Ubuntu

=== Configuration

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

=== Set up database

```bash
./bin/rake db:migrate
./bin/rake db:seed
./bin/rake assets:precompile
```
