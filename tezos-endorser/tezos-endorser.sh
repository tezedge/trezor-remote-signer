#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# wait for remote signer to load, move to Docker file 
sleep 5s 

# register/get public key hash for BIP32 path
PUBLIC_KEY_HASH="$(
    curl --request POST http://$SIGNER_ADDRESS:$SIGNER_PORT/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

if [ -z $PUBLIC_KEY_HASH ]; then
    echo "[-][ERROR][remote-signer] Can not get Tezos address for $HW_WALLET_HD_PATH"
    exit 0;
fi

echo "[+][remote-signer] address: $PUBLIC_KEY_HASH "
echo "[+][remote-signer] path: $HW_WALLET_HD_PATH"
echo "[+][tezos-client] balance: $(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get balance for $PUBLIC_KEY_HASH)"
echo "[+][tezos-client] delegate: $(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get delegate for $PUBLIC_KEY_HASH)"

# register HD wallet for remote signer 
echo -e "\n[+][tezos-client] import remote wallet secret key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import secret key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"

echo -e "\n[+][tezos-client] import remote wallet public key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import public key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"

echo -e "\n[+][tezos-endorser-alpha] launch endorser:\n$(
    tezos-endorser-alpha --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    --remote-signer http://$SIGNER_ADDRESS:$SIGNER_PORT run
)"
