#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# change permissions
chmod 755 /var/tezos-node
ls -la /var/tezos-node

# wait for remote signer to load, move to Docker file 
sleep 3s 

# staking is started by endorser already
# stop staking
"$(curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/stop_staking --silent \
         --header 'Content-Type: application/json' )"


# register/get public key hash for BIP32 path
PUBLIC_KEY_HASH="$(
    curl --request POST http://$SIGNER_ADDRESS:$SIGNER_PORT/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

echo "[+][hw-wallet] address: $PUBLIC_KEY_HASH "

# staking is started by endorser already
# stop staking
"$(curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/start_staking --silent \
         --header 'Content-Type: application/json' )"

echo -e "\n[+][hw-wallet] launch baker:\n$(
    tezos-baker-alpha --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS --remote-signer http://$SIGNER_ADDRESS:$SIGNER_PORT run with local node /var/tezos-node $PUBLIC_KEY_HASH   
)"

