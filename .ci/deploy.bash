#!/bin/bash

set -e

docker build -t brawler-server -f .ci/godot-server-env.dockerfile .
docker save brawler-server | gzip > brawler-server.tar.gz
scp brawler-server.tar.gz azureuser@20.81.125.206:/home/azureuser
ssh azureuser@20.81.125.206 "docker load -i brawler-server.tar.gz"