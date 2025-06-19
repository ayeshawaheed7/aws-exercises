#!/bin/bash

export IMAGE=$1
source ~/.docker-creds.env

echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin
docker-compose -f docker-compose.yaml up --detach
echo 'successfully deployed!'
