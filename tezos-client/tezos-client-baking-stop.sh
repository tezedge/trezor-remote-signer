#!/bin/sh

# reset device
echo -e "[+][remote-signer] Reset device \n$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/reset_device --silent\
        --header 'Content-Type: application/json' )"

# change pin
echo -e "[+][remote-signer] Change pin \n$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/change_pin --silent \
        --header 'Content-Type: application/json' )"

# # start baking mode
# echo -e "[+][remote-signer] Stop Tezos baking mode \n$(
#     curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/stop_staking --silent \
#         --header 'Content-Type: application/json' )"

# stop containers        

