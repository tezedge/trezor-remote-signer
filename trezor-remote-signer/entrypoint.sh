#!/bin/sh
echo "Trezor remote singner"

#trezorctl list

cd ./remote-signer
gunicorn -b 0.0.0.0:5000 -w 4 signer:app