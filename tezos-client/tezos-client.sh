#!/bin/sh
export TEZOS_CLIENT_UNSAFE_DISABLE_DISCLAIMER=Y

# remote Tezos node 
ADDRESS=zeronet.simplestaking.com
PORT=3000

# BIP32 path for Trezor T
HW_WALLET_HD_PATH='"m/44'\''/1729'\''/3'\''"'

# register/get public key hash for BIP32 path
public_key_hash="$(
    curl --request POST http://trezor-remote-signer:5000/register --silent \
         --header 'Content-Type: application/json' \
         --data $HW_WALLET_HD_PATH  | jq -r '.pkh' )"



echo "[+][hw-wallet] address: $public_key_hash "
echo "[+][hw-wallet] path: $HW_WALLET_HD_PATH"
echo "[+][hw-wallet] balance: $(tezos-client --addr $ADDRESS --port $PORT --tls get balance for $public_key_hash)"

# tezos-client --addr $ADDRESS --port $PORT --tls  man -v 3
echo "[+][remote-node] timestamp: $(tezos-client --addr $ADDRESS --port $PORT --tls get timestamp)"

#change direcotry to faucet folder
cd "/var/tezos-client/faucet/"

# activate all wallets from ./faucet direcotry
for file in *
do  
   # remove .json from filename
   faucet_public_key_hash=${file::-5}  
   echo -e "\n[+][wallet] activate: $faucet_public_key_hash"
   
   # activate wallet
   tezos-client --addr $ADDRESS --port $PORT --tls activate account $faucet_public_key_hash with "$file" --force
   balance=$(tezos-client --addr $ADDRESS --port $PORT --tls get balance for $faucet_public_key_hash)

   # default fee for transaction
   FEE=1

   # substract fee from balance
   balance_without_fee="$( awk  -vbalance="${balance::-4}" -vfee="$FEE" 'BEGIN{printf ("%.0f\n",balance-fee)}')"

   echo -e "\n[+][wallet] balance: $balance_without_fee for: $faucet_public_key_hash"
   
   # transfer xtz to hw wallet address
   tezos-client --addr $ADDRESS --port $PORT --tls transfer $balance_without_fee from $faucet_public_key_hash to $public_key_hash --fee 0.1 --fee-cap 1 --burn-cap 1
   
done

# register HD wallet for remote signer 

echo -e "\n[+][hw-wallet] import remote wallet secret key:\n$(
    tezos-client --addr $ADDRESS --port $PORT --tls \
    import secret key $public_key_hash http://trezor-remote-signer:5000/$public_key_hash --force
)"

echo -e "\n[+][hw-wallet] import remote wallet public key:\n$(
    tezos-client --addr $ADDRESS --port $PORT --tls \
    import public key $public_key_hash http://trezor-remote-signer:5000/$public_key_hash --force
)"

# register hw wallet address as delegate 
echo -e "\n[+][hw-wallet] register delegate\n$(
    tezos-client --addr $ADDRESS --port $PORT --tls \
    register key $public_key_hash as delegate --fee 0.1
)"

echo -e "\n[+][hw-wallet] register delegate\n$(
    tezos-client --addr $ADDRESS --port $PORT --tls \
    list known addresses
)"