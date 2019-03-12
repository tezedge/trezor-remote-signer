#!/bin/sh

# login to dockerhub 
docker login --username=simplestakingcom
# tag image 
docker build -t simplestakingcom/trezor-baking-firmware ./trezor-baking-firmware
# upload image to dockerhub
docker push simplestakingcom/trezor-baking-firmware