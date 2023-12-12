FROM ubuntu:latest

WORKDIR /usr/src/app

COPY . .

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    ln -s /usr/src/app/sources.list /etc/apt/  && \
    apt-get update -y && \
    apt-get install -y ruby-full build-essential zlib1g-dev
RUN echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
RUN echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
RUN gem install jekyll bundler

CMD ["bundle", "exec", "jekyll", "serve"]