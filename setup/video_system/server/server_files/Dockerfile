FROM python:3.12-alpine

RUN apk add --no-cache \
    ffmpeg \
    bash \
    mc \
    nano \
    rsync \
    curl \
    cifs-utils \
    findutils \
  && pip install --no-cache-dir croniter requests
