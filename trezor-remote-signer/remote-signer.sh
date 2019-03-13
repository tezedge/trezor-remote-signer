#!/bin/sh
echo "Trezor remote singner"

trezorctl list

# trezorctl tezos-get-address --address "m/44'/1729'/3'"
# trezorctl wipe-device
# trezorctl change-pin
# trezorctl recovery-device
# # enable blood owner few exist much identify shadow online tobacco leave forward
# exit 1

export FLASK_APP=signer.py
export FLASK_ENV=development
cd ./remote-signer

# cat signer.py

flask run --host=0.0.0.0
