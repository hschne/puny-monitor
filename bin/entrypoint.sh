#!/bin/bash
set -e

bundle exec rake db:prepare

exec "$@"
