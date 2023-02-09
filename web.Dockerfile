# Use Ruby 2.3.3 as the base image
FROM ruby:2.3.3-alpine

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock to the working directory
COPY Gemfile Gemfile.lock ./
COPY Rakefile ./

# Set the environment variables
ENV RAILS_ENV production
RUN apk add --no-cache build-base
RUN apk add --no-cache ruby-dev libstdc++
# Install the required libraries for building the mysql2 gem
RUN apk add --no-cache mariadb-dev
RUN apk add --no-cache libxml2-dev libxslt-dev
RUN apk add --no-cache shared-mime-info
RUN apk add --no-cache tzdata

# Copy the rest of the application files
COPY . .

# Install the required gems
RUN bundle install

RUN gem install tzinfo-data

RUN apk add --no-cache nodejs
# Set the timezone to America/Los_Angeles
ENV TZ=Europe/Berlin

# Update the system clock to the specified timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 3000
# Start the application server
CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]

