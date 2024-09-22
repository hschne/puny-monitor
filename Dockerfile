# Dockerfile

FROM ruby:3.3

WORKDIR /puny-monitor
COPY . /puny-monitor

RUN bundle install

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
