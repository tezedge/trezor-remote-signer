#!/bin/sh

# start baking mode
echo -e "[+][remote-signer] Stop Tezos baking mode \n$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/stop_staking --silent \
        --header 'Content-Type: application/json' )"

# stop containers        

