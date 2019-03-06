#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

ADDRESS=zeronet.simplestaking.com
PORT=3000

# tezos-client --addr $ADDRESS --port $PORT --tls set man  -v 3
echo $(tezos-client --addr $ADDRESS --port $PORT --tls get timestamp)
echo $(tezos-client --addr $ADDRESS --port $PORT --tls get balance for tz1Q1FsKNmNyhgbxhtbet2qzJPskPtT8s5nH)