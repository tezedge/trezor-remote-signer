#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# wait for remote signer to load 
sleep 3s 

# change permissions
chmod 755 /var/tezos-node
# ls -la /var/tezos-node

# start staking
"$(curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/start_staking --silent \
         --header 'Content-Type: application/json' )"

# register/get public key hash for BIP32 path
PUBLIC_KEY_HASH="$(
    curl --request POST http://$SIGNER_ADDRESS:$SIGNER_PORT/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

echo "\n[+][remote-signer] hw wallet address: $PUBLIC_KEY_HASH \n"

# register HD wallet for remote signer
echo -e "[+][tezos-client] import wallet public key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import public key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"

echo -e "[+][tezos-client] import wallet secret key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import secret key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"

echo -e "\n[+][tezos-baker-alpha] launch baker:\n$(
    tezos-baker-alpha --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS --remote-signer http://$SIGNER_ADDRESS:$SIGNER_PORT run with local node /var/tezos-node $PUBLIC_KEY_HASH   
)"

