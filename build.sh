#!/bin/bash

# docker build -t kasmvnc-custom:fedora39 .

docker build \
  --no-cache \
  --pull \
  -t kasmvnc-custom:fedora39 .

docker-compose -f ./kasm-webtop.yml up -d

