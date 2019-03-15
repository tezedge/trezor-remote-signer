#!/bin/sh

trezorctl list

# remove old firmware
# rm -rf /tmp/trezor-core/build

# compile new firmware
cd /tmp && \
git clone https://github.com/simplestaking/trezor-core.git && \
cd trezor-core && \
git checkout staking && \
git submodule update --init --recursive && \
make clean vendor build_boardloader build_bootloader build_prodtest build_firmware

# show available firmwares
ls -la trezor-core/build/firmware

# upload compiled firmware
trezorctl firmware-update --filename /tmp/trezor-core/build/firmware/firmware.bin --skip-vendor-header "simplestaking.com"