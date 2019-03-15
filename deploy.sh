#!/bin/sh

# login to dockerhub 
docker login --username=simplestakingcom

# tag trezor-baking-firmware image
docker build -t simplestakingcom/trezor-baking-firmware ./trezor-baking-firmware
# upload image to dockerhub
docker push simplestakingcom/trezor-baking-firmware

# tag trezor-signer
docker build -t simplestakingcom/trezor-signer ./trezor-signer
# upload image to dockerhub
docker push simplestakingcom/trezor-signer