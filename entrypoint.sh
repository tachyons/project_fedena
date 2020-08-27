#!/usr/bin/env bash

# Wait for database to be ready
until nc -z -v -w30 $MYSQL_HOST $MYSQL_PORT; do
 echo 'Waiting for MySQL...'
 sleep 1
done
echo "MySQL is up and running!"
bundle

# If the database exists, migrate. Otherwise setup (create and migrate)
bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:create db:migrate
echo "MySQL database has been created & migrated!"

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# Run the Rails server
bundle exec passenger start -b 0.0.0.0 -p 8080
