#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

chmod 755 /var/tezos-node
ls -la /var/tezos-node

# wait for remote signer to load, move to Docker file 
sleep 3s 

# remote Tezos node 
ADDRESS=zeronet.simplestaking.com
PORT=3000

# BIP32 path for Trezor T
HW_WALLET_HD_PATH='"m/44'\''/1729'\''/3'\''"'

# stop staking
"$(curl --request GET http://trezor-remote-signer:5000/stop_staking --silent \
         --header 'Content-Type: application/json' )"


# register/get public key hash for BIP32 path
public_key_hash="$(
    curl --request POST http://trezor-remote-signer:5000/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

echo "[+][hw-wallet] address: $public_key_hash "

echo -e "\n[+][hw-wallet] launch baker:\n$(
    tezos-baker-alpha --addr $ADDRESS --port $PORT --tls --remote-signer http://trezor-remote-signer:5000 run with local node /var/tezos-node $public_key_hash   
)"

