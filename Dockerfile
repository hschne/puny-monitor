ARG RUBY_VERSION=3.4

FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /puny-monitor

ENV RACK_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development:test"

FROM ruby:${RUBY_VERSION} AS builder

WORKDIR /puny-monitor

ENV RACK_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development:test"


COPY puny-monitor.gemspec Gemfile Gemfile.lock ./
COPY 'lib/puny_monitor/version.rb' 'lib/puny_monitor/version.rb'

RUN bundle install --jobs 4 --retry 3

# Application stage
FROM base

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . .

ENV ROOT_PATH='/host'

EXPOSE 4567
ENTRYPOINT ["bin/entrypoint.sh"]
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
