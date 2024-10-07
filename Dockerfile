# Dockerfile

FROM ruby:3.3

WORKDIR /puny-monitor

COPY . .

RUN bundle install

EXPOSE 4567

ENV ROOT_PATH='/host'

ENTRYPOINT ["bin/entrypoint.sh"]
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
