#!/bin/sh

export

# docker is not waiting for remote signer to boot up move code fron entry to docker file 
sleep 4s

# stop staking
"$(curl --request GET http://$SIGNER_ADDRESS:$SIGNER_PORT/stop_staking --silent \
         --header 'Content-Type: application/json' )"

# wait for flask app to load in trezor-remote-signer, move flask start to Dockerfile  
sleep 4s

# register/get public key hash for BIP32 path
PUBLIC_KEY_HASH="$(
    curl --request POST http://$SIGNER_ADDRESS:$SIGNER_PORT/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"

if [ -z $PUBLIC_KEY_HASH ]; then
    echo "[-][ERROR] Can not get Tezos address for $HW_WALLET_HD_PATH"
    exit 0;
fi

echo "[+][hw-wallet] address: $PUBLIC_KEY_HASH "
echo "[+][hw-wallet] path: $HW_WALLET_HD_PATH"
echo "[+][hw-wallet] balance: $(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get balance for $PUBLIC_KEY_HASH)"

# tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS  man -v 3
echo "[+][remote-node] timestamp: $(tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS get timestamp)"

#change direcotry to faucet folder
cd "/var/tezos-client/faucet/"

# activate all wallets from ./faucet direcotry
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
echo -e "\n[+][hw-wallet] import remote wallet secret key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import secret key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"
echo -e "\n[+][hw-wallet] import remote wallet public key:\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    import public key $PUBLIC_KEY_HASH http://$SIGNER_ADDRESS:$SIGNER_PORT/$PUBLIC_KEY_HASH --force
)"


# register hw wallet address as delegate 
echo -e "\n[+][hw-wallet] register delegate\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    register key $PUBLIC_KEY_HASH as delegate --fee 0.1
)"

echo -e "\n[+][hw-wallet] register delegate\n$(
    tezos-client --addr $NODE_ADDRESS --port $NODE_PORT $NODE_TLS \
    list known addresses
)"