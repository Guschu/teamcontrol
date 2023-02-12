#!/bin/bash

source /etc/profile
set -e
# Remove a potentially pre-existing server.pid for Rails.
rm -f /teamcontrol/tmp/pids/server.pid

bundle exec rake db:migrate
bundle exec rake db:seed

# Then exec the container's main process (what's set as CMD in the web.Dockerfile).
exec "$@"
