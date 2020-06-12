FROM ruby:2.5.3-stretch

# Update the package lists before installing.
RUN apt-get update -qq

# This installs
# * build-essential because Nokogiri requires gcc
# * common CA certs
# * netcat to test the database port
# * the mysql CLI and client library
RUN apt-get install -y \
    build-essential \
    ca-certificates \
    netcat-traditional \
    vim \
    mysql-client \
    default-libmysqlclient-dev


# Create a directory called `/workdir` and make that the working directory
ENV APP_HOME /workdir
RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}

# Copy the Gemfile
COPY Gemfile ${APP_HOME}/Gemfile
COPY Gemfile.lock ${APP_HOME}/Gemfile.lock

# Make sure we are running bundler version 1.17.3
RUN gem install bundler -v 1.17.3
RUN bundle install

# Copy the project over
COPY . ${APP_HOME}

# Map port 8080 to the outside world (your local computer)
EXPOSE 8080

ENTRYPOINT ["sh", "./entrypoint.sh"]
