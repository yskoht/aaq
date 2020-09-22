FROM ruby:2.7.1-alpine

ARG AAQ_VERSION="0.1.4"

RUN apk add --no-cache --virtual=build-deps gcc libc-dev make pkgconfig \
 && apk add --no-cache imagemagick6 imagemagick6-dev imagemagick6-libs \
 && gem install aaq -v ${AAQ_VERSION} \
 && apk del --no-cache build-deps

WORKDIR /root

CMD ["echo", "[usage]: docker run --rm -v $(pwd):/root yskoht/aaq aaq [image] [--color]"]

