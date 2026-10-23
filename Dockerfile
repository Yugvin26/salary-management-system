FROM ruby:3.3.6

RUN ruby -ropen-uri -e 'URI.open("https://nodejs.org/dist/v22.17.1/node-v22.17.1-linux-x64.tar.gz") { |io| IO.copy_stream(io, "/tmp/node.tar.gz") }' \
  && tar -xzf /tmp/node.tar.gz -C /usr/local --strip-components=1 \
  && rm /tmp/node.tar.gz \
  && corepack enable \
  && corepack prepare yarn@1.22.22 --activate

WORKDIR /app
ENV BUNDLE_PATH=/usr/local/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN chmod +x bin/dev bin/docker-entrypoint bin/rails \
  && yarn build

EXPOSE 3000
ENTRYPOINT ["bash", "bin/docker-entrypoint"]
CMD ["bin/dev"]
