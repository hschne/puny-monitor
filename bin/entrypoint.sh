#!/bin/bash
set -e

bundle exec rake db:prepare 2>/dev/null

exec "$@"
