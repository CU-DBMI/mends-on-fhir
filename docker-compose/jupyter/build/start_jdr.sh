#!/usr/bin/env bash

# From: https://devopscube.com/run-docker-in-docker/ How to run docker in docker container [3 easy methods]
# Dockerd fails but it creates /var/run/docker.sock so chmod works

dockerd || chmod 666 /var/run/docker.sock
start-notebook.sh --IdentityProvider.token=''

