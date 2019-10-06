#Use ruby 2.3.3
FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client && apt-get install -y dos2unix

RUN mkdir /teamcontrol
WORKDIR /teamcontrol

COPY Gemfile /teamcontrol/Gemfile
COPY Gemfile.lock /teamcontrol/Gemfile.lock

RUN bundle install

COPY . /teamcontrol


# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN dos2unix /usr/bin/entrypoint.sh && apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 80:3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]