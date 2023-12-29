#!/bin/bash

docker-compose -f ./kasm-webtop.yml stop
docker-compose -f ./kasm-webtop.yml rm -f 
docker rmi kasmvnc-custom:fedora39
# docker rmi kasm-fedora:latest
