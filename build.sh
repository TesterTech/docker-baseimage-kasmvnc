#!/bin/bash

docker build \
  --no-cache \
  --pull \
  -t ghcr.io/linuxserver/baseimage-kasmvnc:fedora39 .

docker-compose -f ./kasm-webtop.yml up -d

