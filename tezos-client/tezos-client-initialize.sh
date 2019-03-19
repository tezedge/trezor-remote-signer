#!/bin/sh

# check for faucet files in faucet directory
if ! [ "$(ls -A /var/tezos-client/faucet/*.json)" ]; then 
    echo "[-][ERROR][trezor-client] Please download faucet files from https://faucet.tzalpha.net/";
    echo "           and save them to ./tezos-client/faucet/"; 
    exit 0;
fi

# Create new Trezor wallet
echo -e "\n[+][remote-signer] Create new Trezor wallet, Confirm by pressing green button on Trezor"
echo -e "$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/reset_device --silent \
         --header 'Content-Type: application/json' )"


# Set new pin
echo -e "\n[+][remote-signer] Set new pin, Confirm by pressing green button on Trezor"
echo -e "$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/change_pin  --silent \
         --header 'Content-Type: application/json' )"


# start baking mode
echo -e "\n[+][remote-signer] Stop Tezos baking mode \n$(
    curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/stop_staking --silent \
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

# show user address
sleep 3s

echo "[+][tezos-client] balance: $(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get balance for $PUBLIC_KEY_HASH)"
echo "[+][tezos-client] timestamp: $(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get timestamp)"

# change directory to faucet folder
cd "/var/tezos-client/faucet/"

# activate all wallets from faucet direcotry
for file in *.json
do  
    # check if file exist
    if [ -f "$file" ];then

        # remove .json from filename
        FAUCET_PUBLIC_KEY_HASH=${file::-5}  
        echo -e "\n[+][wallet] activate: $FAUCET_PUBLIC_KEY_HASH"
        
        # activate wallet
        tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS activate account $FAUCET_PUBLIC_KEY_HASH with "$file" --force
        balance=$(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get balance for $FAUCET_PUBLIC_KEY_HASH)

        # default fee for transaction
        FEE=1

        # substract fee from balance
        balance_without_fee="$( awk  -vbalance="${balance::-4}" -vfee="$FEE" 'BEGIN{printf ("%.0f\n",balance-fee)}')"

        echo -e "\n[+][wallet] balance: $balance_without_fee for: $FAUCET_PUBLIC_KEY_HASH"
        
        # transfer xtz to hw wallet address
        tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS transfer $balance_without_fee from $FAUCET_PUBLIC_KEY_HASH to $PUBLIC_KEY_HASH --fee 0.1 --fee-cap 1 --burn-cap 1
    fi
done

# register HD wallet for remote signer 
echo -e "[+][tezos-client] import wallet key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import secret key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"

read -p "Register delegate [Y/n] " RESPONSE
if ! [ "$RESPONSE" = "y" ] && ! [ "$RESPONSE" = "" ]; then
    exit 0
fi
# register hw wallet address as delegate 
echo -e "\n[+][tezos-client] Register delegate, Confirm by pressing green button on Trezor"
echo -e "$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    register key $PUBLIC_KEY_HASH as delegate --fee 0.1
)"