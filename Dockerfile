FROM ruby:1.9.3
MAINTAINER pomu0326@gmail.com

RUN git clone https://github.com/alpcrimea/webistrano.git /opt/webistrano

WORKDIR /opt/webistrano
RUN bundle install --without test

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"]

EXPOSE 3000
