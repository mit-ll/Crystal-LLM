#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /usr/local/S/Clinical_Studies/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
# exec "$@"

bundle exec rake assets:precompile

# bundle exec rails server -b 0.0.0.0
exec bundle exec "$@"
