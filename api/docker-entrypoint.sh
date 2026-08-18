#!/bin/sh
set -e

# Prepare the database (create + migrate + seed) on every start.
# Retry briefly: Docker's embedded DNS can be momentarily unavailable
# right after the db healthcheck passes.
attempts=30
n=0
until bundle exec rails db:prepare; do
  n=$((n + 1))
  if [ "$n" -ge "$attempts" ]; then
    echo "db:prepare failed after $attempts attempts" >&2
    exit 1
  fi
  echo "db:prepare attempt $n failed, retrying in 2s..."
  sleep 2
done

exec "$@"