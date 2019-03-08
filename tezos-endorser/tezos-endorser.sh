#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# wait for remote signer to load, move to Docker file 
sleep 3s 

# remote Tezos node 
ADDRESS=zeronet.simplestaking.com
PORT=3000

# BIP32 path for Trezor T
HW_WALLET_HD_PATH='"m/44'\''/1729'\''/3'\''"'

# register/get public key hash for BIP32 path
public_key_hash="$(
    curl --request POST http://trezor-remote-signer:5000/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"



echo "[+][hw-wallet] address: $public_key_hash "
echo "[+][hw-wallet] path: $HW_WALLET_HD_PATH"
echo "[+][hw-wallet] balance: $(tezos-client --addr $ADDRESS --port $PORT --tls get balance for $public_key_hash)"

# register HD wallet for remote signer 
echo -e "\n[+][hw-wallet] import remote wallet secret key:\n$(
    tezos-client --addr $ADDRESS --port $PORT --tls \
    import secret key $public_key_hash http://trezor-remote-signer:5000/$public_key_hash --force
)"

echo -e "\n[+][hw-wallet] import remote wallet public key:\n$(
    tezos-client --addr $ADDRESS --port $PORT --tls \
    import public key $public_key_hash http://trezor-remote-signer:5000/$public_key_hash --force
)"

# echo -e "\n[+][hw-wallet] launch endorser:\n$(
#     tezos-endorser-alpha man
# )"

echo -e "\n[+][hw-wallet] launch endorser:\n$(
    tezos-endorser-alpha -l --addr $ADDRESS --port $PORT --tls \
    --remote-signer http://trezor-remote-signer:5000 run
)"

# nohup ./tezos-endorser-alpha --remote-signer http://<signer address>:<signer port> run > endorser.out &
