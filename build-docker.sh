#!/bin/bash

docker build -t eap_proxy_build -f docker/Dockerfile .
docker run --rm -v ${PWD}:/src eap_proxy_build

tree out/
