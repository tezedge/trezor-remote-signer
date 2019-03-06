#!/bin/sh
echo "Trezor remote singner"

#trezorctl list

export FLASK_APP=signer.py
export FLASK_ENV=development
cd ./remote-signer
flask run --host=0.0.0.0