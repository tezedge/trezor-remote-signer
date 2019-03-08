#!/bin/sh
echo "Trezor remote singner"


trezorctl list

# trezorctl wipe-device
# trezorctl list
# enable blood owner few exist much identify shadow online tobacco leave forward

# set trezor pin 
#trezorctl change-pin

export FLASK_APP=signer.py
export FLASK_ENV=development
cd ./remote-signer
flask run --host=0.0.0.0
