FROM ruby:2.6.0-stretch

WORKDIR /app

COPY src/Gemfile src/Gemfile.lock /app/
RUN gem install bundler
RUN bundle install

COPY src/ /app

ENV PORT 8080

CMD exec ruby app.rb -p $PORT -o '0.0.0.0'
