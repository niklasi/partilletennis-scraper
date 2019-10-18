FROM ruby:2.4.9-stretch

COPY src/ /app
WORKDIR /app

RUN gem install bundler
RUN bundle install

ENV PORT 8080

CMD exec ruby app.rb -p $PORT -o '0.0.0.0'
