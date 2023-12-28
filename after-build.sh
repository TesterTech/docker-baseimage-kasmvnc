#!/bin/bash

docker-compose -f ./kasm-webtop.yml stop
docker-compose -f ./kasm-webtop.yml rm -f 
docker rmi ghcr.io/linuxserver/baseimage-kasmvnc:fedora39
# docker rmi kasm-fedora:latest
