FROM ruby:3.0

RUN gem install jekyll bundler

WORKDIR /usr/src/app

COPY . .

CMD ["bundle", "exec", "jekyll", "serve"]