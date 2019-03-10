#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# wait for remote signer to load, move to Docker file 
sleep 5s 

# remote Tezos node 
ADDRESS=zeronet.simplestaking.com
PORT=3000
# ADDRESS=0.0.0.0
# PORT=8732
TLS='--tls'

# SIGNER_ADDRESS=trezor-remote-signer
SIGNER_ADDRESS=localhost
SIGNER_PORT=5000

# BIP32 path for Trezor T
HW_WALLET_HD_PATH='"m/44'\''/1729'\''/3'\''"'

# stop staking
"$(curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/stop_staking \
         --header 'Content-Type: application/json' )"

# register/get public key hash for BIP32 path
public_key_hash="$(
    curl --request POST http://$SIGNER_ADDRESS:$SIGNER_PORT/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"


echo "[+][hw-wallet] address: $public_key_hash "
echo "[+][hw-wallet] path: $HW_WALLET_HD_PATH"
echo "[+][hw-wallet] balance: $(tezos-client --addr $ADDRESS --port $PORT $TLS get balance for $public_key_hash)"

# register HD wallet for remote signer 
echo -e "\n[+][hw-wallet] import remote wallet secret key:\n$(
    tezos-client --addr $ADDRESS --port $PORT $TLS \
    import secret key $public_key_hash http://$SIGNER_ADDRESS:$SIGNER_PORT/$public_key_hash --force
)"

echo -e "\n[+][hw-wallet] import remote wallet public key:\n$(
    tezos-client --addr $ADDRESS --port $PORT $TLS \
    import public key $public_key_hash http://$SIGNER_ADDRESS:$SIGNER_PORT/$public_key_hash --force
)"


# start staking !!! only before 
"$(curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/start_staking --silent \
         --header 'Content-Type: application/json' )"

# echo -e "\n[+][hw-wallet] launch endorser:\n$(
#     tezos-endorser-alpha man
# )"

echo -e "\n[+][hw-wallet] launch endorser:\n$(
    tezos-endorser-alpha --addr $ADDRESS --port $PORT $TLS \
    --remote-signer http://$SIGNER_ADDRESS:$SIGNER_PORT run
)"

# nohup ./tezos-endorser-alpha --remote-signer http://<signer address>:<signer port> run > endorser.out &
