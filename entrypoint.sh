#!/bin/sh

source /etc/profile
set -e

# Source environment variables from .env file
set -a
. .env
set +a

# Remove a potentially pre-existing server.pid for Rails.
rm -f /teamcontrol/tmp/pids/server.pid

bundle exec rake db:migrate
bundle exec rake db:seed
# Precompile the assets
bundle exec rake assets:precompile

# Then exec the container's main process (what's set as CMD in the web.Dockerfile).
exec "$@"
