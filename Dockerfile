FROM ruby:1.9.3
MAINTAINER pomu0326@gmail.com

RUN git clone git://github.com/peritor/webistrano.git /opt/webistrano

WORKDIR /opt/webistrano
RUN gem uninstall bundler -aIx; gem install bundler -v 1.0.10
RUN sed -i -e 's|"rake"|"rake", "0.8.7"|g' Gemfile
RUN bundle install --path vendor/bundler

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000
