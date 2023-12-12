FROM ubuntu:latest

RUN apt-get install ruby-full build-essential zlib1g-dev
RUN echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
RUN echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
RUN gem install jekyll bundler

WORKDIR /usr/src/app

COPY . .

CMD ["bundle", "exec", "jekyll", "serve"]