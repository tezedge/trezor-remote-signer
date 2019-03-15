#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# wait for tezos endorser 
sleep 3s 

# change permissions
# ls -la /var/tezos-node

# start baking mode
echo -e "[+][remote-signer] Start Tezos baking mode \n$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/start_staking --silent \
        --header 'Content-Type: application/json' )"

# register/get public key hash for BIP32 path
PUBLIC_KEY_HASH="$(
    curl --request POST http://$SIGNER_ADDRESS:$SIGNER_PORT/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

if [ -z $PUBLIC_KEY_HASH ]; then
    echo "[-][ERROR][remote-signer] Can not get Tezos address for $HW_WALLET_HD_PATH"
    exit 0;
fi

echo -e "\n[+][remote-signer] address: $PUBLIC_KEY_HASH"
echo -e "[+][remote-signer] path: $HW_WALLET_HD_PATH\n"

# register HD wallet for remote signer 
echo -e "[+][tezos-client] import wallet key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import secret key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"

# launch baker
echo -e "\n[+][tezos-endorser-alpha] baker launched:"
echo -e "$(
    tezos-baker-alpha --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    --remote-signer http://$SIGNER_ADDRESS:$SIGNER_PORT run with local node /var/tezos-node $PUBLIC_KEY_HASH   
)"