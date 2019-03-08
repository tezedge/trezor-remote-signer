#!/bin/sh

# BIP32 path for Trezor T
HW_WALLET_HD_PATH="m/44'/1729'/3'"

trezorctl list
trezorctl get-features
trezorctl tezos-get-address --address $HW_WALLET_HD_PATH

# rm -rf /tmp/trezor-core/build

# compile new firmware
cd /tmp && \
git clone https://github.com/simplestaking/trezor-core.git && \
cd trezor-core && \
git checkout staking && \
git submodule update --init --recursive && \
make clean vendor build_boardloader build_bootloader build_prodtest build_firmware

pwd
ls -la trezor-core/build/firmware

# upload compilet firmware
trezorctl firmware-update --filename /tmp/trezor-core/build/firmware/firmware.bin --skip-vendor-header "simplestaking.com"



#3f0e3a33

# custom firmware 
#1488109b