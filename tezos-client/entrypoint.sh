#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# remote Tezos node 
ADDRESS=zeronet.simplestaking.com
PORT=3000

# BIP32 path for Trezor T
HW_WALLET_HD_PATH='"m/44'\''/1729'\''/3'\''"'

# register/get public key hash for BIP32 path
PUBLIC_KEY_HASH="$(
    curl --request POST http://trezor-remote-signer:5000/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

echo "Address: $PUBLIC_KEY_HASH  path: $HW_WALLET_HD_PATH"

# tezos-client --addr $ADDRESS --port $PORT --tls set man  -v 3
echo $(tezos-client --addr $ADDRESS --port $PORT --tls get timestamp)
echo $(tezos-client --addr $ADDRESS --port $PORT --tls get balance for $PUBLIC_KEY_HASH)